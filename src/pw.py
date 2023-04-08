from json import load
from time import sleep
from bs4 import BeautifulSoup
from tqdm import tqdm
import numpy as np
import pandas as pd
import polars as pl
import os
from dotenv import load_dotenv
from playwright.sync_api import Playwright, sync_playwright

TEST_TICKER = "NOK"
DEBUG_STATE = True

load_dotenv()
YCHART_EMAIL = str(os.environ.get("YCHART_EMAIL"))
YCHART_PASSWORD = str(os.environ.get("YCHART_PASSWORD"))

with open("./ch_data/ticker_list.json") as fj:
    ticker_list = load(fj)


def parse_html_to_df(page_text: str) -> pd.DataFrame:
    soup = BeautifulSoup(page_text, "lxml")
    data_tables = soup.find("div", {"ng-bind-html": "$ctrl.dataTableHtml"})
    tables = data_tables.find_all("table", {"class": "table"})  # type: ignore
    parsed_tables = pd.read_html(str(tables), flavor="lxml")
    df = pd.concat(parsed_tables)
    df.columns = ("date", "value")
    return df


def parse_html_to_pd(page_text: str) -> pd.DataFrame:
    df = parse_html_to_df(page_text)
    df["date"] = pd.to_datetime(df["date"], format="%B %d, %Y")
    df["date"] = df["date"].dt.to_period("M").dt.to_timestamp()
    df["value"] = df["value"].str.strip("%").astype(np.float16)
    return df


def parse_html_to_pl(page_text: str) -> pl.DataFrame:
    df = parse_html_to_df(page_text)
    df["date"] = pd.to_datetime(df["date"], format="%B %d, %Y")
    df["date"] = df["date"].dt.to_period("M").dt.to_timestamp()
    pldf = pl.from_pandas(df)
    pldf = pldf.with_columns(
        pldf["value"].str.replace("%", "").cast(pl.Float64).alias("value")
    )
    return pldf


def run(playwright: Playwright, tickers: list[str]) -> None:
    browser_context = playwright.chromium.launch_persistent_context(
        ".\\ch_data\\", headless=True
    )
    page = browser_context.pages[0]
    # Auth sequence -------
    page.goto("https://ycharts.com/login")
    if page.get_by_text("Welcome back!").is_visible():
        sleep(1)
        page.get_by_placeholder("name@company.com").click()
        page.get_by_placeholder("name@company.com").fill(
            YCHART_EMAIL
        )
        page.get_by_placeholder("Password").click()
        page.get_by_placeholder("Password").fill("YCHART_PASSWORD")
        page.locator("label").filter(has_text="Remember me on this device").click()
        page.get_by_role("button", name="Sign In").click()
    # ---------------------
    if DEBUG_STATE:
        ticker = TEST_TICKER

    filenames = list()
    for file in os.listdir("opm_parqs"):
        filename, _ = os.path.splitext(file)
        filenames.append(filename)

    dfs_pl: list[pl.DataFrame] = []
    for ticker in (pbar := tqdm(tickers)):
        pbar.set_description(f"Processing {ticker}")
        # if ticker in filenames:
        #     pldf = pl.read_parquet(f"./opm_parqs/{ticker}.parquet")
        # else:
        url = f"https://ycharts.com/companies/{ticker}/operating_margin_ttm"
        # print("going to ", url)
        page.goto(url)
        # global page_text
        # page_text = page.content()
        try:
            pldf = (
                parse_html_to_pl(page.content())
                .sort(by="date")
                .groupby_dynamic(index_column="date", every="3mo")
                .agg([pl.mean("value")])
            )
            pldf.columns = ["date", ticker]
            pldf.write_parquet(f"./opm_parqs/{ticker}.parquet")
            dfs_pl.append(pldf)
        except:
            continue

    global df_pl_res
    df_pl_res = dfs_pl
    browser_context.close()


with sync_playwright() as playwright:
    filenames = list()
    for file in os.listdir("opm_parqs"):
        filename, _ = os.path.splitext(file)
        filenames.append(filename)
    last_ticker_idx = ticker_list.index(filenames[-1])
    run(playwright, tickers=ticker_list[last_ticker_idx + 1 :])

# df_merged = df_pl_res[0]
# for df in df_pl_res[1:]:
#     df_merged = df_merged.join(df, on="date", how="outer")
# # df_pl_joined = pl.concat(df_pl_res, how="horizontal")  # type: ignore
# df_merged.write_parquet("test.parquet")
# df_merged.write_csv("test.csv")
# print(df_merged)


# with open(f"{TEST_TICKER}.html", "x") as html_f:
#     html_f.write(page_text)

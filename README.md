# HSE_project
ЭПП Литвинов А. А.
гр. МФИН2021-2023

# How to run
## Step 1
```sh
virtualenv venv
.\venv\Scripts\activate
```

## Step 2
To collect data:
```sh
python .\src\pw.py
```

## Step 3
To merge data:
```sh
python .\src\merging.py
```
Result in `./ch_data/merged.csv`
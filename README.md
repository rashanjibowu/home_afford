# Home Afford

Use this simple command-line application to determine the maximum home you can afford.

## Installation

Just clone the repo and copy the executable file (`home_afford.R`) anywhere you like.

## Usage

Default values

```{r}
./home_afford.R
```

Change your **annual** income to $60,000

```{r}
./home_afford.R --income=60000
```

Change your interest rate to 5.5%

```{r}
./home_afford.R --rate=0.055
```

Remove the **monthly** condo fee (default is $400/mo)

```{r}
./home_afford.R --condo-fee=0
```

Change your **annual** property taxes (default is $10,000/yr)

```{r}
./home_afford.R --taxes=4500
```

Change the maximum loan-to-value (LTV) to 75% (default is 80%)

```{r}
./home_afford.R --ltv=0.75
```

Add other **monthly** debt payments, like credit cards or student loans (default is $0/mo.)

```{r}
./home_afford.R --debts=160
```

Any combination of these will work, too!

```{r}
./home_afford.R --income=55000 --debts=160 --rate=0.045 --condo-fee=250 --taxes=4750
```

If you need help...

```{r}
./home_afford.R --h
```

## Happy House Hunting!

If you have suggestions for improvement, [submit an issue](https://github.com/rashanjibowu/home_afford/issues/new)!
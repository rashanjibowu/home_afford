#!/usr/bin/env Rscript
#
# This program calculates the maximum home you can afford given certain
# financing and income assumptions
# Adapted from: https://gist.github.com/econ-r/dcd503815bbb271484ff

## functions

setValue <- function(args, flag, default) {
    regex <- paste0("^", flag, "*")
    result <- grep(pattern = regex, x = args, value = TRUE)

    if (length(result) == 0) return(default)

    # we have a value, so return that value
    # strip out the value after the delimiter "="
    components <- strsplit(x = result[1], split = "=")
    value <- as.numeric(components[[1]][2])

    return(ifelse(value <= 0, default, value))
}

displayHelp <- function() {
    cat("\r\n")
    cat("Home Afford\r\n")
    cat("\tThis program calculates the maximum home you can afford given certain assumptions\r\n")
    cat("\r\n")
    cat("Usage:\r\n")
    cat("\t--income\tSpecifies annual income. Default is 100000 ($100,000)\r\n")
    cat("\t--debts\t\tSpecifies monthly value of other debt payments, like credit cards\r\n")
    cat("\t--taxes\t\tSpecifies annual property taxes on the property. Default is 10000 ($10,000)\r\n")
    cat("\t--condo-fee\tSpecifies monthly condo fee. Default is 400\r\n")
    cat("\t--rate\t\tSpecifies annual rate of interest on the mortgage. Default is 0.04 (4.0%)\r\n")
    cat("\t--ltv\t\tSpecifies maximum loan to value. Default is 0.8 (80%)\r\n")
    cat("\r\n")
}

PMT <- function(rate, nper,pv, fv=0, type=0){
    pmt = ifelse(rate!=0,
                 (rate*(fv+pv*(1+ rate)^nper))/((1+rate*type)*(1-(1+ rate)^nper)),
                 (-1*(fv+pv)/nper )
    )

    return(pmt)
}

IPMT <- function(rate, per, nper, pv, fv=0, type=0){
    ipmt = -( ((1+rate)^(per-1)) * (pv*rate + PMT(rate, nper,pv, fv=0, type=0)) - PMT(rate, nper,pv, fv=0, type=0))
    return(ipmt)
}

PPMT <- function(rate, per, nper, pv, fv=0, type=0){
    ppmt = PMT(rate, nper,pv, fv=0, type=0) - IPMT(rate, per, nper, pv, fv=0, type=0)
    return(ppmt)
}

NPER <- function(rate, pmt, pv, fv=0, type=0){
    nper = ifelse(rate!=0,
                  log10((pmt*(1+rate*type)-fv*rate)/(pmt*(1+rate*type)+pv*rate)) / log10(1+rate),
                  -1*(fv+pv)/pmt )
    return(nper)
}

PV.excel <- function(rate, nper, pmt, fv=0, type=0){
    if(length(pmt)>1){
        stop("The payment made each period cannot change over the life of the annuity")
    }
    pv = ifelse(rate!=0,
                sapply(rate, function(r)
                    - (fv + pmt*(1+r*type)*(((1+r)^nper)-1)/r)/(1+r)^nper),
                -(fv + (pmt*nper))
    )

    return(data.frame('Rate'=rate, 'Periods'=nper, 'PV'=pv))
}

FV.excel <- function(rate, nper, pmt, pv=0, type=0){
    if(length(pmt)>1){
        stop("The payment made each period cannot change over the life of the annuity")
    }
    fv = ifelse(rate!=0,
                sapply(rate, function(r)
                    (pmt*(1+r*type)*(1-(1+ r)^nper)/r)-pv*(1+r)^nper ),
                -1*(pv+pmt*nper)
    )
    return(data.frame('Rate'=rate, 'Periods'=nper, 'FV'=fv))
}

# user may also pass in values for income, debts, taxes, LTV, rate, and condo fee
args <- commandArgs(trailingOnly = TRUE)

requestedHelp <- length(grep(pattern = "--h|--help", x = args)) > 0

if (requestedHelp) {
    displayHelp()
}

if (!requestedHelp) {

    # You
    annual_income <- setValue(args, "--income", default = 100000)
    existing_monthly_debt_payments <- setValue(args, "--debts", default = 0)

    # Property
    property_tax <- setValue(args, "--taxes", default = 10000)
    condo_fee <- setValue(args, "--condo-fee", default = 400)

    # Financing
    max_loan_to_value <- setValue(args, "--ltv", default = 0.8)
    mortgage_rate <- setValue(args, "--rate", default = 0.04)
    max_debt_to_income <- 0.33

    ## Calculations

    max_monthly_payment_PI = annual_income / 12 * max_debt_to_income - existing_monthly_debt_payments - condo_fee - property_tax / 12
    total_monthly_payment <- max_monthly_payment_PI + condo_fee + property_tax / 12

    max_loan <- PV.excel(rate = mortgage_rate / 12, nper = 12 * 30, pmt = -1 * max_monthly_payment_PI)
    max_home_value <- max_loan$PV / max_loan_to_value
    equity <- max_home_value - max_loan$PV

    print(sprintf("You can afford a home worth $%s, assuming you have $%s in the bank",
                  format(x = max_home_value, big.mark = ",", digits = 3),
                  format(x = equity, big.mark = ",", digits = 3)))
    print(sprintf("Principal and interest: $%0.2f/mo.", max_monthly_payment_PI))
    print(sprintf("With taxes and condo fees: $%0.2f/mo.",total_monthly_payment))
}

@echo off
:: Use this line of code for debugging purposes *** Adapt the paths for R installation and R script!!!
::"C:\Program Files\R\R-3.5.1\bin\R.exe" CMD BATCH "D:\TradingRepos\R_tradecontrol\_RL\Adapt_RL_control.R"
:: Use this code in 'production'
"C:\Program Files\R\R-3.5.1\bin\Rscript.exe" "D:\TradingRepos\R_tradecontrol\_RL\Adapt_RL_control.R"
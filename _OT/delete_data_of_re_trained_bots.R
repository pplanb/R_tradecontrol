## Delete records related to re-trained trading robots [specific to FALCON A]
library(tidyverse)
library(magrittr)
source("D:/TradingRepos/R_tradecontrol/import_data.R")
source("D:/TradingRepos/R_tradecontrol/get_profit_factorDF.R")
source("D:/TradingRepos/R_tradecontrol/writeCommandViaCSV.R")

# trader will train the robot in Terminal 3
# new files will be generated
# trader will run bat file to move files 
# additionally this R script will be activated with following steps:

# Read file with orders in the T1
# Read file and read magic numbers of robots to be re-trained
# Filter out magic numbers with re-trained robots
# Write command trade active = 0 for re-trained ssytems in T3
# Write file with remaining orders back to T1


# read files 
# terminal 1 path
path_T1 <- "D:/FxPro - Terminal1/MQL4/Files/"
# File Setup.csv should contain magic numbers of the working systems 
path_PRJCT_1 <- "D:/TradingRepos/FALCON_A/"

DFT1 <- try(import_data(path_T1, "OrdersResultsT1.csv"), silent = TRUE)

# find systems that would have require optimization
DFT_x <- DFT1 %>%  # filtered to contain last 20 orders for each system
      group_by(MagicNumber) %>% 
      arrange(MagicNumber, desc(OrderCloseTime)) %>% 
      filter(row_number() <= 8) %>% 
      get_profit_factorDF(7) %>% 
      ungroup() %>% 
      filter(PrFact < 1) %>% 
      select(MagicNumber, PrFact) %>% 
      mutate(ToOptimize = 1) %>% 
      inner_join(y = read_csv(file = file.path(path_PRJCT_1,"TEST", "Setup.csv"), 
                              col_types = "cci"), 
                 by = c("MagicNumber" = "Magic")) %>% 
  select(MagicNumber)

# exclude results from DFT_x (unprofitable systems)
DFT_x1 <- DFT1 %>% 
   anti_join(DFT_x, by = "MagicNumber")  
  
# disable systems in the slave terminal before deleting them
# terminal 3 path *** make sure to customize this path
path_T3 <- "D:/FxPro - Terminal3/MQL4/Files/"

# delete control parameters of affected systems
# vector of magic number names
control_files <- DFT_x %$% MagicNumber

for (CTRLN in control_files) {
tryCatch({
    # CTRLN <- 8118103
  CTRL_FILE <- file.path("D:/TradingRepos/R_tradecontrol/_RL/control", paste0(CTRLN, ".rds"))
  if(file.exists(CTRL_FILE)){
    file.remove(CTRL_FILE)
  }
}, error=function(e){cat("ERROR :",conditionMessage(e), "\n")})
  
}

# generate trading systems with correct magic number to disactivate
DFT_x %>% 
  mutate(MagicNumber = MagicNumber + 200, 
         IsEnabled = 0) %>% 
  # Write command "disable"
  writeCommandViaCSV(path_T3)

# write file OrdersResultsT1.csv unfortunately old records will not be visible for trading journal :)
write_csv(DFT_x1, path = file.path(path_T1, "OrdersResultsT1.csv"),col_names = F)



#coursera_04_ExploratoryDataAnalysis/project01 2015
#verify some basic requirements like platform is correct

switch(Sys.info()[['sysname']],
       Windows= {print("This a Windows PC. This script was not written for it ! \n It may not work correctly  ")},
       Linux  = {print("This is  Gnu/Linux Os it should work like a charm. be sure wget is installed")},
       Darwin = {print("Welcome to you Happy Mac user. This script was written under Linux but maybe it works with  a Mac")}
    )
if (!"sqldf" %in% rownames(installed.packages())) {
  print("I need the sqldf package to filter the data I will import and it seems it is not installed so I will try to install it")
  install.packages("sqldf")
}
library(sqldf)
#some basic constants variables 
data_url <- "https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2Fhousehold_power_consumption.zip"
data_archive_filename <- "exdata_data_household_power_consumption.zip"
data_dir <- "data/"      # local directory where the archive will be extracted
data_filename <- paste(data_dir,"household_power_consumption.txt",sep = "")
#load archive if it's not already there
if (!file.exists(data_archive_filename)){ 
  print(paste(" I will try to download data archive file from : ", data_url))
  op_result <- download.file(data_url, destfile = data_archive_filename, method = "wget")
  if (op_result != 0) {
    print(paste("### ERROR downloading with wget the data archive file from : ", data_url))
    print("### may be you should check if wget is installed and if you have access to internet" )
    stop(paste("### ERROR status CODE was : ",op_result))            
  } 
} else {
  print(paste(" I found the archive of data here : ", getwd(), data_archive_filename, sep = ""))
}
# test if archive already extracted by testing directory and presence of the dataset
if (!file.exists(data_dir) && (!file.exists(data_filename))){
  unzip(data_archive_filename,exdir = data_dir)
} else {
  print(paste("+ I found the dataset here : ", getwd(), data_filename, sep = ""))
  print(paste("+ I think the archive was already extracted ..."))
  print(paste("+ so I decide to go on with this data ..."))
}
# The following descriptions of the 9 variables in the dataset are taken from the UCI web site:
# https://archive.ics.uci.edu/ml/datasets/Individual+household+electric+power+consumption
# 1 - Date: Date in format dd/mm/yyyy
# 2 - Time: time in format hh:mm:ss
# 3 - Global_active_power: household global minute-averaged active power (in kilowatt)
# 4 - Global_reactive_power: household global minute-averaged reactive power (in kilowatt)
# 5 - Voltage: minute-averaged voltage (in volt)
# 6 - Global_intensity: household global minute-averaged current intensity (in ampere)
# 7 - Sub_metering_1: energy sub-metering No. 1 (in watt-hour of active energy). It corresponds to the kitchen, containing mainly a dishwasher, an oven and a microwave (hot plates are not electric but gas powered).
# 8 - Sub_metering_2: energy sub-metering No. 2 (in watt-hour of active energy). It corresponds to the laundry room, containing a washing-machine, a tumble-drier, a refrigerator and a light.
# 9 - Sub_metering_3: energy sub-metering No. 3 (in watt-hour of active energy). It corresponds to an electric water-heater and an air-conditioner.
print("Now i will read the data inside a dataframe, (variable df) but only for those dates : 2007-02-01 and 2007-02-02")
df <- read.csv2.sql(data_filename, ,sql = "select * from file where Date = '1/2/2007' OR Date = '2/2/2007'")
df$Date <- as.Date(df$Date, format="%d/%m/%Y")
datetime <- paste(as.Date(df$Date), df$Time)
#strptime gives a Posixlt but what I really need is to convert it to Posixct format 
#df$Datetime <- strptime(datetime,"%Y-%m-%d %H:%M:%S")
df$Datetime <- as.POSIXct(strptime(datetime,"%Y-%m-%d %H:%M:%S"))
print("Here is what df looks like after the date and time  'format crunching' to get a valid one for this plot  :")
str(df)
print("Now I need to adjust the locale because I'm not on an english computer and days are in french...")
if (Sys.getlocale(category = "LC_TIME") != "en_US.UTF-8") {
  Sys.setlocale(category = "LC_TIME","en_US.UTF-8")
}
## Plot 4
print("Now let's make a nice plot to screen with the Global active power per day ")
#using dev.copy can have some neirds side effects so i use the png() function for the official result image
# i also decide to put a white backgroung based on discussion from 
# https://class.coursera.org/exdata-014/forum/thread?thread_id=13
png(filename = "plot4.png", height=480, width=480)
par(mfrow = c(2, 2))
with(df,
     {
       plot(Global_active_power~Datetime, type="l",ylab="Global Active Power", xlab="")
       plot(Voltage~Datetime, type="l",ylab="Voltage", xlab="datetime")
       plot(Sub_metering_1~Datetime, type="l",ylab="Energy sub metering", xlab="",col = "black")
       lines(Sub_metering_2~Datetime, type="l", col = "red")
       lines(Sub_metering_3~Datetime, type="l", col = "blue") 
       legend("topright",bty="n" , lty = 1, col = c("black", "red", "blue"), legend = c("Sub_metering_1", "Sub_metering_2", "Sub_metering_3"))
       plot(Global_reactive_power~Datetime, type="l",ylab="Global_reactive_power", xlab="datetime")
     }
)
dev.off()


### Imagery QA/QC 

#####################################################################################
### Prep the groundtruth data
### groundtruth corresponds to image files that Caira checked for mussel presence. 
### If the photo is in groundtruth, it truly exists and has an ID assigned. 
cairaGT <- read.csv("Horse Mussel Groundtruthing_working1.csv", stringsAsFactors = F) 
dim(cairaGT) #3202    5
groundtruth <- read.csv("Horse Mussel Groundtruthing_final.csv", stringsAsFactors = F)
dim(groundtruth) #3204    5
### so Caira added two rows to the final groundtruthing dataset. Let's keep going on this "final" version 

groundtruth$Mussels. <- as.factor(groundtruth$Mussels.)
levels(groundtruth$Mussels.) <- c("NA", "MusselReef", "Shells")

# change the names to match nav data
names(groundtruth) <- c("Year", "STATION_NUM", "ID.Date", "PHOTO_FILE_NAME", "Mussels")

# check classes, make them match nav data if necessary
str(groundtruth)

# create a unique ID for each photo
groundtruth$unid <- paste0(groundtruth$STATION_NUM, "_", groundtruth$PHOTO_FILE_NAME)

# subset for each year
groundtruth2009 <- groundtruth[groundtruth$Year==2009,]
groundtruth2011 <- groundtruth[groundtruth$Year==2011,]

dim(groundtruth2009) # has 1773 rows
dim(groundtruth2011) # has 1431 rows

#####################################################################################
### Prep the navigation data
### these nav files are from the initial data dump from Kate (corresponds to files in Working Files 1)
### nav2009 and nav2011 are spatial metadata for the photos
### need to match the nav metadata to the groundtruth data so that we can identify mussel locations
caira2009 <- read.csv("2009 CSV Format for R_working1.csv", stringsAsFactors = F) 
dim(caira2009) #1769   25
caira2011 <- read.csv("2011 CSV Format for R_working1.csv", stringsAsFactors = F) 
dim(caira2011) #1348   25


nav2009 <- read.csv("2009 CSV Format for R_final.csv", stringsAsFactors = F)
dim(nav2009) #1718   25
nav2011 <- read.csv("2011 CSV Format for R_final.csv", stringsAsFactors = F)
dim(nav2011) #1287   25

### so caira removed 1769-1718 = 51 rows from the 2009 nav data
### and 1348-1287 = 61 rows from the 2011 nav data

nav2011$PHOTO_FILE_NAME <- as.character(nav2011$PHOTO_FILE_NAME)

# create a unique ID for each photo. Hypothetically, this should correspond to the groundtruth unid
nav2009$unid <- paste0(nav2009$STATION_NUM, "_", nav2009$PHOTO_FILE_NAME)
nav2011$unid <- paste0(nav2011$STATION_NUM, "_", nav2011$PHOTO_FILE_NAME)

dim(nav2009) # has 1769 rows
dim(nav2011) # has 1348 rows

#####################################################################################
### caira's remaining unresolved error lists are in "Y:/Caira/NRCAN Photo Data/Unresolved..."
# 2009 has 47 nav records with missing photos
# 2011 has 59 nav records with missing photos

# below are double checks of what Caira did (NOT DONE!!):
#####################################################################################
### Inner join the photos and nav data (these records are presumably CLEAN)
require(dplyr)
join2009_clean <- inner_join(nav2009, groundtruth2009)
dim(join2009_clean) # 1718   29
join2011_clean <- inner_join(nav2011, groundtruth2011)
dim(join2011_clean) # 1287   29

### following must be true
### EXPED_CD is only found in nav df, ID.Date is only found in groundtruth df. If either are >0, that means there is an issue.
length(join2009_clean$unid[is.na(join2009_clean$EXPED_CD)])==0
length(join2009_clean$unid[is.na(join2009_clean$ID.Date)])==0
length(join2011_clean$unid[is.na(join2011_clean$EXPED_CD)])==0
length(join2011_clean$unid[is.na(join2011_clean$ID.Date)])==0

#####################################################################################
### full join the photos (df groundtruth2009/2011) and the nav data (df nav2009/2011)
join2009_full <- full_join(nav2009, groundtruth2009) 
dim(join2009_full) # 1773   29
### so this means that there are 1773-1718 = 55 rows that are "missing" from one or the other
### since there were 1773 records in groundtruth 2009, it is likely that there are more photos than nav data records
length(join2009_full$unid[is.na(join2009_full$EXPED_CD)]) #55
length(join2009_full$unid[is.na(join2009_full$ID.Date)]) #0


join2011_full <- full_join(nav2011, groundtruth2011) 
dim(join2011_full) # 1431   29
### so this means that there are 1431-1287 = 144 rows that are "missing" from one or the other
length(join2011_full$unid[is.na(join2011_full$EXPED_CD)]) #55
length(join2011_full$unid[is.na(join2011_full$ID.Date)]) #0


#####################################################################################
### left join the photos on the nav
join2009_left <- left_join(nav2009, groundtruth2009)
dim(join2009_left) # 1718   29
### so this likely means that we have more groundtruth records (i.e. photos) than we have nav data, 
### meaning that nav records are missing

length(join2009_left$unid[is.na(join2009_left$ID.Date)])==0
### this shows that some of the nav records do not correspond to a photo

#####################################################################################
### right join the photos on the nav
join2009_right <- right_join(nav2009, groundtruth2009)
dim(join2009_right) # 1773   29
### so we have more photos than nav data, and we can identify the photos without nav data 
photoswithoutnav <- join2009_right[is.na(join2009_right$EXPED_CD),]


# > dim(read.csv("Y:/Caira/NRCAN Photo Data/Data Checks/Old Data Check/2009 CSV Format for R.csv"))
# [1] 1769   25
# > dim(read.csv("Y:/Caira/NRCAN Photo Data/Data Checks/Old Data Check/2011 CSV Format for R.csv"))
# [1] 1348   25
# > dim(read.csv("Y:/Caira/NRCAN Photo Data/Data Checks/Working Files 1/2009 CSV Format for R_working1.csv"))
# [1] 1769   25
# > dim(read.csv("Y:/Caira/NRCAN Photo Data/Data Checks/Working Files 1/2011 CSV Format for R_working1.csv"))
# [1] 1348   25
# > dim(read.csv("Y:/Caira/NRCAN Photo Data/Data Checks/Working Files 2/2009 CSV Format for R_working2.csv"))
# [1] 1764   25
# > dim(read.csv("Y:/Caira/NRCAN Photo Data/Data Checks/Working Files 2/2011 CSV Format for R_working2.csv"))
# [1] 1345   25
# > dim(read.csv("Y:/Caira/NRCAN Photo Data/Data Checks/Working Files 3/2009 CSV Format for R_working3.csv"))
# [1] 1718   25
# > dim(read.csv("Y:/Caira/NRCAN Photo Data/Data Checks/Working Files 3/2011 CSV Format for R_working3.csv"))
# [1] 1287   25
# > dim(read.csv("Y:/Caira/NRCAN Photo Data/Data Checks/Final Files/2009 CSV Format for R_final.csv"))
# [1] 1718   25
# > dim(read.csv("Y:/Caira/NRCAN Photo Data/Data Checks/Final Files/2011 CSV Format for R_final.csv"))
# [1] 1287   25
# > dim(read.csv("Y:/Caira/NRCAN Photo Data/Data Checks/All errors removed/2009 CSV Format for R.csv"))
# [1] 1764   25
# > dim(read.csv("Y:/Caira/NRCAN Photo Data/Data Checks/All errors removed/2011 CSV Format for R.csv"))
# [1] 1345   25



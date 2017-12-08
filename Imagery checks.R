### Imagery QA/QC 

#####################################################################################
### Prep the groundtruth data
### groundtruth corresponds to image files that Caira checked for mussel presence. 
### If the photo is in groundtruth, it truly exists and has an ID assigned. 
groundtruth <- read.csv("Horse Mussel Groundtruthing.csv")

groundtruth$Mussels. <- as.factor(groundtruth$Mussels.)
levels(groundtruth$Mussels.) <- c("NA", "MusselReef", "Shells")

# change the names to match nav data
names(groundtruth) <- c("Year", "STATION_NUM", "ID.Date", "PHOTO_FILE_NAME", "Mussels")

# create a unique ID for each photo
groundtruth$unid <- paste0(groundtruth$STATION_NUM, "_", groundtruth$PHOTO_FILE_NAME)

# subset for each year
groundtruth2009 <- groundtruth[groundtruth$Year==2009,]
groundtruth2011 <- groundtruth[groundtruth$Year==2011,]

dim(groundtruth2009) # has 1773 rows
dim(groundtruth2011) # has 1431 rows

#####################################################################################
### Prep the navigation data
### nav2009 and nav2011 are spatial metadata for the photos
### need to match the nav metadata to the groundtruth data so that we can identify mussel locations

nav2011 <- read.csv(paste0(yfolder, "/2011 CSV Format for R.csv"))
nav2009 <- read.csv(paste0(yfolder, "/2009 CSV Format for R.csv"))

# create a unique ID for each photo. Hypothetically, this should correspond to the groundtruth unid
nav2009$unid <- paste0(nav2009$STATION_NUM, "_", nav2009$PHOTO_FILE_NAME)
nav2011$unid <- paste0(nav2011$STATION_NUM, "_", nav2011$PHOTO_FILE_NAME)

dim(nav2009) # has 1718 rows
dim(nav2011) # has 1287 rows

#####################################################################################
### Left join the photos (df groundtruth2009/2011) on the nav data (df nav2009/2011)
require(dplyr)
join2009.1 <- left_join(nav2009, groundtruth2009) 


join2009.1 <- join(groundtruth2009, nav2009, type="left")
join2009.1.in <- join(groundtruth2009, nav2009, type="inner")
join2009.1.full <- join(groundtruth2009, nav2009, type="full")
join2009.2 <- join(nav2009, groundtruth2009, type="left")
join2009.2.in <- join(nav2009, groundtruth2009, type="inner")
join2009.2.full <- join(nav2009, groundtruth2009, type="full")

dim(join2009.1)
dim(join2009.1.in)
dim(join2009.1.full)
dim(join2009.2)
dim(join2009.2.in)
dim(join2009.2.full)
dim(nav2009)
dim(groundtruth2009)

head(join2009.1)
head(join2009.2)
str(join2009.2)

dim(join2009.1[is.na(join2009.1$EXPED_CD),]) ### 55 records missing from nav2009. These are the same 2009 records that Caira found in her report
join2009.1[is.na(join2009.1$EXPED_CD),]$unid

notinnav2009 <- groundtruth2009[groundtruth2009$unid %in% join2009.1[is.na(join2009.1$EXPED_CD),]$unid,]

length(unique(notinnav2009$unid))

require(dplyr)
join2009.2 <- arrange(join2009.2, unid)
join2009.1.comp <- join2009.1[!is.na(join2009.1$EXPED_CD),]
join2009.1.comp <- arrange(join2009.1.comp, unid)

unique(join2009.2$unid == join2009.1.comp$unid)
# ok so join2009.2 and join2009.1.comp contain only full records, and are identical. 
# join2009.1 contains 55 records with missing data. There are 55 photos for which there is no nav data, 
# but there is a photo for every nav record


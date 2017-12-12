###
# Join NRCAN Photo Location data
###

setwd('Y:/Caira/NRCAN Photo Data/Data Checks/Final Files')
options(stringsAsFactors=FALSE)

#import data

nav.2009 <- read.csv('2009 CSV Format for R_final.csv')
nav.2011 <- read.csv('2011 CSV Format for R_final.csv')
mussels <- read.csv('Horse Mussel Groundtruthing_final.csv')

dim(nav.2009) 
#[1] 1722   25 - FINAL
## [1] 1718   25

#[1] 1764   25 

dup_rem <- read.csv("Y:/Caira/NRCAN Photo Data/Data Checks/Working Files 1/2009 CSV Format for R_Edited_DuplicatesRemoved.csv")
#1768 - from 2009 CSV Format for R_Edited_DuplicatesRemoved.csv
dim(dup_rem)
#[1] 1769   27
## [1] 1768   25

dim(nav.2011)
#[1] 1287   25

#[1] 1345   25 
#[1] 1348   27

dim(mussels)
#3204

EXPED_CD, STATION_NUM, PHOTO_FILE_NAME
year, Track, ID.Number 


nav.2009$year <- 2009
nav.2011$year <- 2011

length(unique(nav.2009$STATION_NUM))
# 33 - FINAL
# 34
length(unique(nav.2011$STATION_NUM))
# 21 - FINAL

ImageStnYr<- paste(mussels$Year, mussels$Track, sep=".")
length(unique(ImageStnYr))
stns.fromImages<- unique(ImageStnYr)
#56

#length(unique(mussels$Track))
# 52

#55 stations but images only from 52 stations - original data - FINAL SUMMARY
stns.2009 <- unique(nav.2009$STATION_NUM)
stns.2011 <- unique(nav.2011$STATION_NUM)


# Y:\Caira\NRCAN Photo Data\Data Checks\All errors removed\StationSummary
#write.csv(stns.2009, 'stns.2009.csv')
#write.csv(stns.2011, 'stns.2011.csv')
#write.csv(stns.fromImages, 'stns.fromImages.csv')


#56 stations but images only from 52 stations - original data

nav <- rbind(nav.2009, nav.2011)
dim(nav)
#[1] 3009   26 - FINAL
# 3005 25????

#3116

#Left Join
loc.mussels <- merge(nav, mussels, by.x=c("year","STATION_NUM","PHOTO_FILE_NAME"), by.y=c("Year","Track","ID.Number"), all.x=TRUE)
dim(loc.mussels)
#[1] 3009   28 - FINAL

#[1] 3116   28

#[1] 3005   28

#Left Join
loc.mussels <- merge(nav, mussels, by.x=c("year","STATION_NUM","PHOTO_FILE_NAME"), by.y=c("Year","Track","ID.Number"), all.x=TRUE)
dim(loc.mussels)
# 3202   28 - FINAL

#[1] 3203   28

#[1] 3005   28
dim(mussels) 
#3204

#NOTE: in 2009 more nav records than images; in 2011 more images than nav records
table(mussels$Year) 
#2009 2011  - FINAL
#1773 1431 

table(nav$year) 
#2009 2011  - FINAL
#1722 1287 

#2009 2011   
#1764 1345 

# 2009 2011 
# 1718 1287 

mussels$ImageFile <- 'imageDat'

#Left Join 2009 Data
loc.2009 <- merge(nav.2009, mussels, by.x=c("year","STATION_NUM","PHOTO_FILE_NAME"), by.y=c("Year","Track","ID.Number"), all.x=TRUE)
dim(loc.2009)
#[1] 1722   29 - FINAL

#[1] 1764   29 

#[1] 1718   29


unique(loc.2009$ImageFile)

loc.2009.missing <- loc.2009[is.na(loc.2009$ImageFile),]
dim(loc.2009.missing)
#[1]  4 29 - FINAL

#[1] 46 29 

#[1]  0 29

write.csv(loc.2009.missing, 'leftJoin2009navOnImageMissing_Sept82017_V2.csv')
#46 nav files in 2009 do not have a matching image file - FINAL
#50 nav files in 2009 do not have a matching image file 


#51 nav files in 2009 do not have a matching image file - from 2009 CSV Format for R_Edited_DuplicatesRemoved.csv

#136 nav files in 2009 do not have a matching image file 

#Left Join 2011 Data
loc.2011 <- merge(nav.2011, mussels, by.x=c("year","STATION_NUM","PHOTO_FILE_NAME"), by.y=c("Year","Track","ID.Number"), all.x=TRUE)
dim(loc.2011)
#[1] 1287   29 - FINAL

#[1] 1345   29


unique(loc.2011$ImageFile)

loc.2011.missing <- loc.2011[is.na(loc.2011$ImageFile),]
dim(loc.2011.missing)
#[1]  0 29

#[1] 58 29 


#write.csv(loc.2011.missing, 'leftJoin2011navOnImageMissing_Sept82017_V2.csv')
#58 nav files in 2011 do not have a matching image file  - FINAL


#61 nav files in 2011 do not have a matching image file 

#138 nav files in 2011 do not have a matching image file 

#0 nav files in 2011 do not have a matching image file

#######
mus.2009 <- mussels[mussels$Year==2009,]
mus.2011 <- mussels[mussels$Year==2011,]
nav.2009$nav <- 'nav'
nav.2011$nav <- 'nav'

#Right Join 2011 Data
loc.2011 <- merge(nav.2011, mus.2011, by.x=c("year","STATION_NUM","PHOTO_FILE_NAME"), by.y=c("Year","Track","ID.Number"), all.y=TRUE)
dim(loc.2011)
#[1] 1431   29

unique(loc.2011$nav)
loc.2011.missing <- loc.2011[is.na(loc.2011$nav),]
dim(loc.2011.missing)
#[1] 144  30

#[1] 221  30

#write.csv(loc.2011.missing, 'RightJoin2011navOnImageMissing_Aug222017.csv')
#144 images have missing nav data

#211 images have missing nav data



#Right Join 2009 Data
loc.2009 <- merge(nav.2009, mus.2009, by.x=c("year","STATION_NUM","PHOTO_FILE_NAME"), by.y=c("Year","Track","ID.Number"), all.y=TRUE)
dim(loc.2009) 
#[1] 1772   30
# !!!! problem with join since only 1771 images --- getting back 1773 records - at least 1 image is duplicated in the nav table 

#getting duplicate for 2009.35.142936

#loc.2009$DUPID <- paste(loc.2009$year,loc.2009$STATION_NUM,loc.2009$PHOTO_FILE_NAME,sep=".")
#sort(table(loc.2009$DUPID) )


unique(loc.2009$nav)
loc.2009.missing <- loc.2009[is.na(loc.2009$nav),]
dim(loc.2009.missing)
#[1] 139  30

#write.csv(loc.2009.missing, 'RightJoin2009navOnImageMissing.csv')
#139 images have missing nav data








write.csv(loc.2009, 'RightJoin2009navOnImages.csv')

#Left Join 2011 Data
loc.2011 <- merge(nav.2011, mussels, by.x=c("year","STATION_NUM","PHOTO_FILE_NAME"), by.y=c("Year","Track","ID.Number"), all.y=TRUE)
dim(loc.2011)
[1] 1348   29

unique(loc.2011$ImageFile)

loc.2011.missing <- loc.2011[is.na(loc.2011$ImageFile),]


write.csv(loc.2011.missing, 'leftJoin2011navOnImageMissing.csv')
#138 nav files in 2011 do not have a matching image file 





#Find duplicate combinations of "unique combo" of EXPED_CD, STATION_NUM, PHOTO_FILE_NAME  OR   year, Track, ID.Number 

nav.2009 <- read.csv('2009 CSV Format for R.csv')
nav.2011 <- read.csv('2011 CSV Format for R.csv')
mussels <- read.csv('Horse Mussel Groundtruthing.csv')


#Find records with missing station, lat/lon, time, or photo name
nav.2009[is.na(nav.2009$STATION_NUM),]
nav.2011[is.na(nav.2011$STATION_NUM),]

mussels[is.na(mussels$Track),]

nav.2009[is.na(nav.2009$PHOTO_LAT),]
nav.2011[is.na(nav.2011$PHOTO_LAT),]
nav.2009[is.na(nav.2009$PHOTO_LONG),]
nav.2011[is.na(nav.2011$PHOTO_LONG),]

nav.2009[is.na(nav.2009$PHOTO_GMT),]
nav.2011[is.na(nav.2011$PHOTO_GMT),]

nav.2009[is.na(nav.2009$PHOTO_FILE_NAME),]
nav.2011[is.na(nav.2011$PHOTO_FILE_NAME),]


#Find duplicate combinations of "unique combo" of EXPED_CD, STATION_NUM, PHOTO_FILE_NAME  OR   year, Track, ID.Number 

nav.2009$CNT <-1
nav.2009$UID <- paste(nav.2009$EXPED_CD,'.',nav.2009$STATION_NUM,'.',nav.2009$PHOTO_FILE_NAME, sep='')
dups <- tapply(nav.2009$CNT,INDEX=(nav.2009$UID), FUN=sum)
str(dups)
dups <- as.data.frame(dups)
dups[dups$dups>1,]


nav.2011$CNT <-1
nav.2011$UID <- paste(nav.2011$EXPED_CD,'.',nav.2011$STATION_NUM,'.',nav.2011$PHOTO_FILE_NAME, sep='')
dups <- tapply(nav.2011$CNT,INDEX=(nav.2011$UID), FUN=sum)
str(dups)
dups <- as.data.frame(dups)
dups[dups$dups>1,]


nav.2011$CNT <-1
nav.2011$UID <- paste(nav.2011$EXPED_CD,'.',nav.2011$STATION_NUM,'.',nav.2011$PHOTO_FILE_NAME, sep='')
dups <- tapply(nav.2011$CNT,INDEX=(nav.2011$UID), FUN=sum)
str(dups)
dups <- as.data.frame(dups)
dups[dups$dups>1,]


mussels$CNT <-1
mussels$UID <- paste(mussels$Year,'.',mussels$Track,'.',mussels$ID.Number, sep='')
dups <- tapply(mussels$CNT,INDEX=(mussels$UID), FUN=sum)
str(dups)
dups <- as.data.frame(dups)
dups[dups$dups>1,]






dupsForCheck <- dups[dups$dups>1,]
write.csv(dupsForCheck,'DuplicatesToCheck.csv')

dim(dups[dups$dups>1,])
[1] 66








#Nav file == 3117 records
# 66 have duplicate --- i.e. 3117 + 66 duplicates = 3183




loc.mussels[loc.mussels$UID==2009.21.194814,]

#Records where no images found: 
loc.mussels[is.na(loc.mussels$ID.Date),] 


loc.mussels <- merge(nav, mussels, by.x=c("year","STATION_NUM","PHOTO_FILE_NAME"), by.y=c("Year","Track","ID.Number"))
#inner join
[1] 2726   28


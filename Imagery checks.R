### Imagery QA/QC 

require(dplyr)

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
caira2009$unid <- paste0(caira2009$STATION_NUM, "_", as.character(caira2009$PHOTO_FILE_NAME))
caira2011$unid <- paste0(caira2011$STATION_NUM, "_", as.character(caira2011$PHOTO_FILE_NAME))
nav2009$unid <- paste0(nav2009$STATION_NUM, "_", nav2009$PHOTO_FILE_NAME)
nav2011$unid <- paste0(nav2011$STATION_NUM, "_", nav2011$PHOTO_FILE_NAME)

dim(nav2009) # has 1718 rows
dim(nav2011) # has 1287 rows

#####################################################################################
### caira's remaining unresolved error lists are in "Y:/Caira/NRCAN Photo Data/Unresolved..."
# 2009 has 47 nav records with missing photos
# 2011 has 59 nav records with missing photos
### Jessica said to ignore these. We will not bother tracking down the photos for these records at this time.

# below are double checks of what Caira did (NOT DONE!!):
#####################################################################################
### Inner join the photos and nav data (these records are presumably CLEAN)
# require(dplyr)
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
### all true, so every nav record is associated with a photo, and vice versa!
### This is our CLEAN dataset (dfs join2009_clean and join2011_clean)

#####################################################################################
### full join the photos (df groundtruth2009/2011) and the nav data (df nav2009/2011)
join2009_full <- full_join(nav2009, groundtruth2009) 
dim(join2009_full) # 1773   29
### so this means that there are 1773-1718 = 55 rows that are "missing" from one or the other
### since there were 1773 records in groundtruth 2009, it is likely that there are more photos than nav data records
length(join2009_full$unid[is.na(join2009_full$EXPED_CD)]) #55
length(join2009_full$unid[is.na(join2009_full$ID.Date)]) #0
### confirmed. we have 55 photos missing a nav record in 2009

### let's also do this join backwards
join2009_full_2 <- full_join(groundtruth2009, nav2009) 
dim(join2009_full_2) # 1773   29
### so this means that there are 1773-1718 = 55 rows that are "missing" from one or the other
length(join2009_full_2$unid[is.na(join2009_full_2$EXPED_CD)]) #55
length(join2009_full_2$unid[is.na(join2009_full_2$ID.Date)]) #0
### same results
### confirmed. we have 55 photos missing a nav record in 2009


join2011_full <- full_join(nav2011, groundtruth2011) 
dim(join2011_full) # 1431   29
### so this means that there are 1431-1287 = 144 rows that are "missing" from one or the other
length(join2011_full$unid[is.na(join2011_full$EXPED_CD)]) #144
length(join2011_full$unid[is.na(join2011_full$ID.Date)]) #0
### confirmed. we have 144 photos missing a nav record in 2011

### let's also do this join backwards
join2011_full_2 <- full_join(groundtruth2011, nav2011) 
dim(join2011_full_2) # 1431   29
### so this means that there are 1431-1287 = 144 rows that are "missing" from one or the other
length(join2011_full_2$unid[is.na(join2011_full_2$EXPED_CD)]) #144
length(join2011_full_2$unid[is.na(join2011_full_2$ID.Date)]) #0
### same results
### confirmed. we have 144 photos missing a nav record in 2011

#####################################################################################
### left join the photos on the nav
join2009_left <- left_join(nav2009, groundtruth2009)
dim(join2009_left) # 1718   29
### so this likely means that we have more groundtruth records (i.e. photos) than we have nav data, 
### meaning that nav records are missing

length(join2009_left$unid[is.na(join2009_left$ID.Date)])==0
length(join2009_left$unid[is.na(join2009_left$EXPED_CD)])==0
### because this join is normalized on nav records, we have all nav records and there are no nav records missing photos in this df

#####################################################################################
### right join the photos on the nav
join2009_right <- right_join(nav2009, groundtruth2009)
dim(join2009_right) # 1773   29

### so we definitely have more photos than nav data

### Let's identify the photos without nav data 
photoswithoutnav2009 <- join2009_full[is.na(join2009_full$EXPED_CD),]
dim(photoswithoutnav2009) # 55 29
View(photoswithoutnav2009)
summary(photoswithoutnav2009)
table(photoswithoutnav2009$STATION_NUM)

## something happened at station 5. Caira noted that there were 41 nav records from station 4 that did not have photos. Could these be station 5 nav records?
## need to look at the photo_file_names from photoswithoutnav2009 to be sure
fromcairaslist <- as.character(c(193654, 193724, 193754, 193820, 193852, 193922, 193954, 194026,
 194052, 194122, 194152, 194220, 194242, 194322, 194422, 194454,
 194522, 194548, 194622, 194652, 194720, 194752, 194854, 194918,
 194954, 195022, 195052, 195124, 195156, 195222, 195254, 195322,
 195354, 195424, 195452, 195524, 195550, 195624, 195654, 195724,
 195754))
unique(fromcairaslist == c(photoswithoutnav2009$PHOTO_FILE_NAME[photoswithoutnav2009$STATION_NUM==5]))
### the photo_file_names all match

table(nav2009[nav2009$STATION_NUM%in% c(4,5),]$STATION_NUM)
table(groundtruth2009[groundtruth2009$STATION_NUM%in% c(4,5),]$STATION_NUM)
### so contrary to what CC report says, there are photos attributed to station 5 in groundtruth2009, and they do not match a nav2009 record. We do NOT have more nav records than photos.
### did she remove them from the final file? Maybe they are still in the original?
table(caira2009[caira2009$STATION_NUM%in% c(4,5),]$STATION_NUM)
### we have 100 nav records for 2009 station 4 and none for 5. We have 59 + 41 photos from stations 4 and 5. Likely that 51 of the station 4 records should be for station 5.
### check the photo_file_names to be sure
check <- c(caira2009$PHOTO_FILE_NAME[caira2009$STATION_NUM == 4 & caira2009$PHOTO_FILE_NAME > 190000])
check <- check[!is.na(check)]
unique(fromcairaslist == check)
### all true, so i think we can safely grab the nav2009 records from station 4 where photo_file_name > 190000 and change station_num to 5. Then re-join with groundtruth2009.
length(check)
nav2009 <- rbind(nav2009, caira2009[caira2009$STATION_NUM == 4 & caira2009$PHOTO_FILE_NAME > 190000,])         
nav2009 <- nav2009[!is.na(nav2009$STATION_NUM),]
length(nav2009$STATION_NUM[nav2009$STATION_NUM == 4 & nav2009$PHOTO_FILE_NAME > 190000]) == 41

nav2009$STATION_NUM[nav2009$STATION_NUM == 4 & nav2009$PHOTO_FILE_NAME > 190000] <- 5
nav2009$unid <- paste0(nav2009$STATION_NUM, "_", nav2009$PHOTO_FILE_NAME)

### do the full join again for photos (df groundtruth2009) and the nav data (df nav2009)
join2009_full <- full_join(nav2009, groundtruth2009) 
dim(join2009_full) # 1773   29
### so this means that there are 1773-1759 = 14 rows that are "missing" from one or the other
### since there were 1773 records in groundtruth 2009, it is likely that there are more photos than nav data records
length(join2009_full$unid[is.na(join2009_full$EXPED_CD)]) #14
length(join2009_full$unid[is.na(join2009_full$ID.Date)]) #0
### confirmed. we have 14 photos missing a nav record in 2009

### now let's recreate photoswithoutnav2009 again
photoswithoutnav2009 <- join2009_full[is.na(join2009_full$EXPED_CD),]
dim(photoswithoutnav2009) # 14 29
View(photoswithoutnav2009)
summary(photoswithoutnav2009)
table(photoswithoutnav2009$STATION_NUM)

### are these all valid station numbers?
table(nav2009$STATION_NUM[nav2009$STATION_NUM %in% unique(photoswithoutnav2009$STATION_NUM)])
### yes. so we see that we have plenty of matched photos from these stations, so these photos may have issues with their photo_file_names. I am NOT going to bother trying to recover these 14 nav records as we have matched photo/nav for many photos
### at these stations. Good enough. Let's move ahead without these 14 photos. 

### but wait, do any of these photos show mussel reef? If so they are extra valuable and I should try to match them up. 
unique(photoswithoutnav2009$Mussels)
### some have shells, but no mussels
photoswithoutnav2009[photoswithoutnav2009$Mussels=="Shells",]

# dim(nav2009[nav2009$unid=="23_115508" | nav2009$PHOTO_FILE_NAME=="115508" | nav2009$STATION_NUM==23,]) # definitely not there. Fortunately, we have other photos from this station so this shouldnt matter
# dim(nav2009[nav2009$unid=="24_98" | nav2009$PHOTO_FILE_NAME=="98" | nav2009$STATION_NUM==24,]) # definitely not there. Fortunately, we have other photos from this station so this shouldnt matter
# dim(nav2009[nav2009$unid=="35_144206" | nav2009$PHOTO_FILE_NAME=="144206" | nav2009$STATION_NUM==35,]) # definitely not there. Fortunately, we have other photos from this station so this shouldnt matter

### CLEAN DF FOR 2009: 
clean2009 <- join2009_full[!is.na(join2009_full$EXPED_CD),]
dim(clean2009) # 1759   29
length(unique(clean2009$unid))
write.csv(clean2009, "clean2009.csv")


### now we'll do the same checks for 2011. based on Caira's report, station 2 and 29 had issues. 
### Let's identify the photos without nav data
photoswithoutnav2011 <- join2011_full[is.na(join2011_full$EXPED_CD),]
dim(photoswithoutnav2011) # 144 29
View(photoswithoutnav2011)
summary(photoswithoutnav2011) 
table(photoswithoutnav2011$STATION_NUM)

### let's focus on stations 9, 52, 69, 121 and 178

## Caira noted that there were 55 nav records from station 29 that did not have photos. Let's check out these records to see if any patterns pop out.
## need to look at the photo_file_names from photoswithoutnav2009 to be sure
fromcairaslist <- as.character(c(291, 292, 293, 294, 295, 296, 297, 303, 304, 305, 306, 307, 308, 309, 310, 311, 312,
 313, 314, 315, 322, 323, 324, 325, 326, 327, 328, 329, 330, 331, 332, 333, 336,
 337, 338, 339, 340, 341, 342, 343, 344, 345, 346, 347, 348, 350, 351, 358, 359,
 362, 363, 364, 365, 366, 367))
photoswithoutnav2011[photoswithoutnav2011$STATION_NUM == 29,] # none
nav2011[nav2011$STATION_NUM == 29,] # none
nav2011[nav2011$STATION_NUM == 9,] # none
groundtruth2011[groundtruth2011$STATION_NUM == 9,] # 77 6
unique(join2011_full$EXPED_CD[join2011_full$STATION_NUM==9]) #  all NA so station 9 is missing from full join
unique(join2011_full$ID.Date[join2011_full$STATION_NUM==29]) #  all NA so station 29 is missing from full join
## does it exist in original nav2011 df?
caira2011[caira2011$STATION_NUM == 9,] # no records for station 9 in original nav data
length(unique(caira2011$PHOTO_FILE_NAME[caira2011$STATION_NUM == 29])) # 55 records for station 29 in the ORIGINAL nav data
groundtruth2011[groundtruth2011$STATION_NUM == 29,] # no photos labelled station 29 
sort(unique(groundtruth2011$STATION_NUM)) # compared to the folder names in Photos/2011036. 55 Items in Station 0009. No station 29.
length(unique(groundtruth2011$PHOTO_FILE_NAME[groundtruth2011$STATION_NUM == 9])) # 77. Why are there more records than there are photos? 
### photos 298 - 302, 316 - 321, 334, 335, 349, 352-357, 360-361 are missing from folder!
### 55 + 5 + 6 + 3 + 6 + 2 = 77
### I suspect that the station_num 29 nav data corresponds to station_num 9 photos. Let's change caira2011 station_num 29 to 9, then rejoin.

### a few final checks
groundtruth2011[groundtruth2011$PHOTO_FILE_NAME %in% unique(caira2011$PHOTO_FILE_NAME[caira2011$STATION_NUM == 29]) & groundtruth2011$STATION_NUM == 9,]
unique(photoswithoutnav2011$STATION_NUM[photoswithoutnav2011$PHOTO_FILE_NAME %in% fromcairaslist])
### the photo_file_names all match

nav2011 <- rbind(nav2011, caira2011[caira2011$STATION_NUM == 29,])         
nav2011 <- nav2011[!is.na(nav2011$STATION_NUM),]
length(nav2011$STATION_NUM[nav2011$STATION_NUM == 29]) == 55

nav2011$STATION_NUM[nav2011$STATION_NUM == 29] <- 9
nav2011$unid <- paste0(nav2011$STATION_NUM, "_", nav2011$PHOTO_FILE_NAME)

### do the full join again for photos (df groundtruth2009) and the nav data (df nav2009)
join2011_full <- full_join(nav2011, groundtruth2011) 
dim(join2011_full) # 1431   29
### so this means that there are 1431-1342=89 rows that are "missing" from one or the other
### since there were 1431 records in groundtruth 2011, it is likely that there are more photos than nav data records
length(join2011_full$unid[is.na(join2011_full$EXPED_CD)]) #89
length(join2011_full$unid[is.na(join2011_full$ID.Date)]) #0
### confirmed. we have 89 photos missing a nav record in 2011

### now let's recreate photoswithoutnav2011 again
photoswithoutnav2011 <- join2011_full[is.na(join2011_full$EXPED_CD),]
dim(photoswithoutnav2011) # 89 29
View(photoswithoutnav2011)
summary(photoswithoutnav2011)
table(photoswithoutnav2011$STATION_NUM) 

### are these all valid station numbers?
table(nav2011$STATION_NUM[nav2011$STATION_NUM %in% unique(photoswithoutnav2011$STATION_NUM)])
### yes, and we have plenty of valid/matched photos, so these photos may have issues with their photo_file_names. I am NOT going to bother trying to recover these 89 nav records as we have matched photo/nav for many photos
### at these stations. Good enough. Let's move ahead without these 89 photos. 

### but wait, do any of these photos show mussel reef? If so they are extra valuable and I should try to match them up. 
unique(photoswithoutnav2011$Mussels)
### no mussels or shells so we can probably get rid of these.
photoswithoutnav2011[photoswithoutnav2011$Mussels=="Shells",]

# dim(nav2009[nav2009$unid=="23_115508" | nav2009$PHOTO_FILE_NAME=="115508" | nav2009$STATION_NUM==23,]) # definitely not there. Fortunately, we have other photos from this station so this shouldnt matter
# dim(nav2009[nav2009$unid=="24_98" | nav2009$PHOTO_FILE_NAME=="98" | nav2009$STATION_NUM==24,]) # definitely not there. Fortunately, we have other photos from this station so this shouldnt matter
# dim(nav2009[nav2009$unid=="35_144206" | nav2009$PHOTO_FILE_NAME=="144206" | nav2009$STATION_NUM==35,]) # definitely not there. Fortunately, we have other photos from this station so this shouldnt matter

### CLEAN DF FOR 2011: 
clean2011 <- join2011_full[!is.na(join2011_full$EXPED_CD),]
dim(clean2011) # 1342   29
length(unique(clean2011$unid))
### write.csv(clean2011, "clean2011.csv")
### NOPE! Go down further (Line 625). While the records above all have nav data associated with a groundtruthing record, there are photos missing from our photo directory.


####################################################################################################### 
### DATA SUMMARY

require(plyr)
length(unique(clean2009$STATION_NUM)) # 34 stations with photos
stations2009 <- ddply(.data=clean2009, .(PHOTO_LAT, PHOTO_LONG),
                      summarize,
                      stations=length(unique(STATION_NUM)),
                      photos = length(PHOTO_FILE_NAME),
                      numphotos = length(unique(PHOTO_FILE_NAME)))
stations2009[stations2009$stations > 1,] # so each station relates to a specific set of coordinates
stations2009[stations2009$numphotos > 1,] # there were a few instances where 2 photos were taken at the exact same location/station. This is fine. 
dim(stations2009) # 1754 different locations (5 locations had 2 photos taken)

### how many photos were scrapped? were any stations completely removed?
dim(clean2009)
dim(groundtruth2009) ## 14 photos were removed
folders2009 <- list.files("Y:/Caira/NRCAN Photo Data/Photos/2009039/")
folders2009 <- as.numeric(folders2009)
folders2009 <- folders2009[!is.na(folders2009)]
nphotos <- NULL
filenames <- NULL
photosper <- NULL
for(i in 1:length(folders2009)){
 nphotos[i] <- length(list.files(paste0("Y:/Caira/NRCAN Photo Data/Photos/2009039/", folders2009[i]), pattern = "*.JPG")) + 
   length(list.files(paste0("Y:/Caira/NRCAN Photo Data/Photos/2009039/", folders2009[i]), pattern = "*.jpg"))
 filenames[i] <- data.frame(names = c(list.files(paste0("Y:/Caira/NRCAN Photo Data/Photos/2009039/", folders2009[i]), pattern = "*.JPG"), 
                   list.files(paste0("Y:/Caira/NRCAN Photo Data/Photos/2009039/", folders2009[i]), pattern = "*.jpg")))
 photos <- data.frame(nphotos=nphotos[i], folder=folders2009[i])
 photosper <- rbind(photosper, photos)
}
sum(nphotos) == dim(groundtruth2009)[1]
photoswithoutnav2009$unid 
#  [1] "23_115508"Y "24_98"Y     "32_102358"N "34_133926"N "35_142936"Y "35_144206"Y "36_154850"N "51_156"Y    "55_174158"Y*2 "55_174148"N "55_174200"N "58_95256"N 
# [13] "73_120156"Y "73_152112"N
## of the photos without nav data in 2009, 7 do not actually correspond to a photo in the folder directory. Is this due to typos or what? Presumably since
## there were more photos listed in groundtruth and in clean2009 than there are in the directory, these are typos and never really existed. 
sum(nphotos) == dim(groundtruth2009)[1] - 7
## the one remaining discrepancy is likely because there are 2 photos attributed to 55_174158 in the directory, but only one in groundtruth2009. This is fine. 

photoswithoutnav2009$directory <- c("Y", "Y", "N", "N", "Y", "Y", "N", "Y", "Y", "N", "N", "N", "Y", "N")

dim(photoswithoutnav2009[photoswithoutnav2009$directory == "Y",])[1]

### so that means that only 7 photos did not have nav data associated! So all stations almost certainly have clean records.

### but are there photos in the clean records that don't actually exist?
photos2009_chk <- ddply(clean2009, .(STATION_NUM),
                        summarize,
                        photos_clean=length(unique(unid)))
photosper$STATION_NUM <- as.numeric(gsub(x=photosper$folder, pattern="200903900", replacement= ""))
photos2009_chk <- full_join(photos2009_chk, photosper)
photos2009_chk[!photos2009_chk$photos_clean == photos2009_chk$nphotos,]
### since there are more photos in the directory than in clean, clean2009 is fine.




photos2009 <- ddply(clean2009, .(STATION_NUM, Mussels),
                    summarize,
                    mean_lat=mean(PHOTO_LAT),
                    mean_lon=mean(PHOTO_LONG),
                    num_photos=length(unique(unid)))

length(unique(photos2009$STATION_NUM[photos2009$Mussels %in% c("MusselReef", "Shells")])) #17 stations with Reef OR Shells
length(unique(photos2009$STATION_NUM[photos2009$Mussels %in% c("MusselReef")])) #1 stations with Reef
length(unique(photos2009$STATION_NUM[photos2009$Mussels %in% c("Shells")])) #16 stations with Shells

photos2009[photos2009$Mussels %in% c("MusselReef"),] # 4 photos of mussel reef
clean2009$unid[clean2009$Mussels %in% c("MusselReef")] # station 32, photos 103130, 103430, 103546, 103944
# groundtruth2009[groundtruth2009$Mussels == "MusselReef",] 

require(ggplot2)
require(rgdal)
require(sp)
require(raster)
maritimes_sp <- readOGR("Y:/Maps/shp/Maritimes_UTM.shp")
maritimes_sp <- spTransform(maritimes_sp, CRS("+proj=longlat +datum=WGS84"))
maritimes_sp <- crop(maritimes_sp, extent(-67.35, -62.9, 43.35, 46.2))
maritimes <- fortify(maritimes_sp)

levels(photos2009$Mussels) <- c("0", "2", "1")
photos2009$Mussels <- factor(photos2009$Mussels, levels = c("0", "1", "2"))
photos2009$Mussels <- as.numeric(photos2009$Mussels)
photos2009_plot <- ddply(.data=photos2009, .(STATION_NUM),
                         summarize, 
                         mean_lat = mean(mean_lat),
                         mean_lon = mean(mean_lon),
                         Mussels = max(as.numeric(Mussels)),
                         NumPhotos = sum(num_photos))
# photos2009_plot <- ddply(.data=clean2009, .(STATION_NUM),
#                          summarize, 
#                          Mussels = max(as.numeric(Mussels)),
#                          NumPhotos = length(unique(unid)))
photos2009_plot$Mussels <- as.factor(photos2009_plot$Mussels)
levels(photos2009_plot$Mussels) <- c("Absent", "Shells", "Reef")

### MUSSEL RESULTS
ggplot() + 
  geom_polygon(data=maritimes, aes(long, lat, group=group), fill="darkgrey", colour="black") +
  geom_point(data=photos2009_plot %>% arrange(Mussels), aes(mean_lon, mean_lat, colour=Mussels), size=3) + theme_bw() + theme(panel.grid=element_blank()) +
  coord_map() + 
  ggtitle("2009 Images")

### PHOTO COUNTS
ggplot() + 
  geom_polygon(data=maritimes, aes(long, lat, group=group), fill="darkgrey", colour="black") +
  geom_point(data=photos2009_plot, aes(mean_lon, mean_lat, size=NumPhotos), alpha=0.5) + theme_bw() + theme(panel.grid=element_blank()) +
  coord_map() + 
  ggtitle("2009 Photos")

require(rgdal) 
require(maptools)
require(mapplots)
require(raster)
#require(shapefiles)
require(reshape2)
#require(mapproj)
require(rgeos)
require(dplyr)

maritimes_UTM <- spTransform(maritimes_sp, CRS("+proj=utm +zone=20 +datum=WGS84 +units=m +no_defs"))
maritimes_UTM <- fortify(maritimes_UTM)

clean2009utm <- read.csv("clean2009_utm.csv", stringsAsFactors = F)
clean2009utm$Mussels <- as.factor(clean2009utm$Mussels)
clean2009utm <- dplyr::select(clean2009utm, unid, POINT_X, POINT_Y)
clean2009 <- left_join(clean2009, clean2009utm)


levels(clean2009$Mussels) <- c("0", "2", "1")
clean2009$Mussels <- factor(clean2009$Mussels, levels = c("0", "1", "2"))
clean2009$Mussels <- as.numeric(clean2009$Mussels)

photos2009_tile <- ddply(.data=clean2009, .(STATION_NUM, POINT_X, POINT_Y),
                         summarize, 
                         Mussels = max(as.numeric(Mussels)),
                         NumPhotos = length(unique(unid)))

mapagg_2009 <- make.grid(x = photos2009_tile$POINT_X,
                    y = photos2009_tile$POINT_Y,
                    z = photos2009_tile$NumPhotos, 
                    byx = 10000, byy = 10000, 
                    xlim = c(186500, 385700), ylim = c(4885000, 5022000), 
                          fun = sum)
mapagg_2009 <- melt(mapagg_2009)

colnames(mapagg_2009) <- c("LongUTM", "LatUTM", "NumPhotos")

options(scipen=999)
png("photo distribution 2009.png", height=500, width=800, res=100)
ggplot() + 
  geom_tile(data=mapagg_2009[!is.na(mapagg_2009$NumPhotos),],aes(LongUTM,LatUTM,fill=NumPhotos))+
  geom_polygon(data=maritimes_UTM, aes(long, lat, group=group), fill="darkgrey", colour=NA) +
  scale_fill_gradient(name="Number of photos",guide="legend",low = "yellow", high = "red") + 
  theme_bw() + theme(panel.grid=element_blank()) + 
  coord_cartesian(xlim = c(175500, 426700), ylim = c(4854000, 5053000)) +
  ylab("Latitude") +
  xlab("Longitude") + 
  ggtitle("2009 imagery")
dev.off()

mapmuss_2009 <- make.grid(x = photos2009_tile$POINT_X,
                         y = photos2009_tile$POINT_Y,
                         z = photos2009_tile$Mussels, 
                         byx = 10000, byy = 10000, 
                         xlim = c(186500, 385700), ylim = c(4885000, 5022000), 
                         fun = max)
mapmuss_2009 <- melt(mapmuss_2009)

colnames(mapmuss_2009) <- c("LongUTM", "LatUTM", "Mussels")

options(scipen=999)
png("mussel distribution 2009.png", height=500, width=800, res=100)
ggplot() + 
  geom_tile(data=mapmuss_2009[!is.na(mapmuss_2009$Mussels),],aes(LongUTM,LatUTM,fill=as.factor(Mussels)))+
  geom_polygon(data=maritimes_UTM, aes(long, lat, group=group), fill="darkgrey", colour=NA) +
  scale_fill_manual(name="Mussel presence",guide="legend", breaks=c(1,2,3), values=c("yellow", "orange", "red"), labels=c("Absent", "Shells", "Reef")) + 
  theme_bw() + theme(panel.grid=element_blank()) + 
  coord_cartesian(xlim = c(175500, 426700), ylim = c(4854000, 5053000)) +
  ylab("Latitude") +
  xlab("Longitude") + 
  ggtitle("2009 imagery")
dev.off()





### 2011
### how many photos were scrapped? were any stations completely removed?
dim(clean2011)
dim(groundtruth2011) ## 89 photos were removed
folders2011 <- as.character(list.files("Y:/Caira/NRCAN Photo Data/Photos/2011036/"))
folders2011 <- as.numeric(folders2011)
require(stringr)
folders2011 <- str_pad(folders2011,width = 4, side = "left",pad = 0)
folders2011 <- folders2011[!is.na(folders2011)]
nphotos11 <- NULL
filenames11 <- NULL
photosper <- NULL
for(i in 1:length(folders2011)){
  nphotos11[i] <- length(list.files(paste0("Y:/Caira/NRCAN Photo Data/Photos/2011036/", folders2011[i]), pattern = "*.JPG")) + 
    length(list.files(paste0("Y:/Caira/NRCAN Photo Data/Photos/2011036/", folders2011[i]), pattern = "*.jpg"))
  filenames11[i] <- data.frame(names = c(list.files(paste0("Y:/Caira/NRCAN Photo Data/Photos/2011036/", folders2011[i]), pattern = "*.JPG"), 
                                       list.files(paste0("Y:/Caira/NRCAN Photo Data/Photos/2011036/", folders2011[i]), pattern = "*.jpg")))
  photos <- data.frame(nphotos=nphotos11[i], folder=folders2011[i])
  photosper <- rbind(photosper, photos)
}
sum(nphotos11) == dim(groundtruth2011)[1] ## 92 photos not in directory but in groundtruth2011.
groundtruth_photos <- ddply(.data=groundtruth2011, .(STATION_NUM),
                            summarize,
                            groundphotos = length(unique(unid)))
groundtruth_photos$folder <- str_pad(groundtruth_photos$STATION_NUM,width = 4, side = "left",pad = 0)
groundtruthphotos_chk <- full_join(groundtruth_photos, photosper)
groundtruthphotos_chk[!groundtruthphotos_chk$groundphotos == groundtruthphotos_chk$nphotos,]

photos2011 <- ddply(clean2011, .(STATION_NUM, Mussels),
                    summarize,
                    mean_lat=mean(PHOTO_LAT),
                    mean_lon=mean(PHOTO_LONG),
                    num_photos=length(unique(unid)))

photos2011$folder <- str_pad(photos2011$STATION_NUM,width = 4, side = "left",pad = 0)
photos2011_chk <- ddply(.data=photos2011, .(folder),
                        summarize,
                        photos_clean = sum(num_photos))
groundtruthphotos_chk <- full_join(groundtruthphotos_chk, photos2011_chk)

groundtruthphotos_chk[!groundtruthphotos_chk$groundphotos == groundtruthphotos_chk$photos_clean,]
groundtruthphotos_chk[!groundtruthphotos_chk$nphotos == groundtruthphotos_chk$photos_clean,]
### there are 2 stations where the number of photos in the CLEAN dataset is greater than the number of possible photos (stn 35 and 69)
### investigate these:
filenames11
sort(clean2011$PHOTO_FILE_NAME[clean2011$STATION_NUM==35])
### Station 35 photo 411 is missing!

sort(clean2011$PHOTO_FILE_NAME[clean2011$STATION_NUM==69])
### Station 69 photo 69020 and 69029 are missing!

clean2011 <- clean2011[!clean2011$unid %in% c("35_411", "69_69020", "69_69029"),]

### Now we're really clean. 
#write.csv(clean2011, "clean2011.csv")

clean2011 <- read.csv("clean2011.csv")

### 2011
require(plyr)
dim(clean2011)
length(unique(clean2011$STATION_NUM)) # 22 stations with photos
stations2011 <- ddply(.data=clean2011, .(PHOTO_LAT, PHOTO_LONG),
                      summarize,
                      stations=length(unique(STATION_NUM)),
                      photos = length(PHOTO_FILE_NAME),
                      numphotos = length(unique(PHOTO_FILE_NAME)))
stations2011[stations2011$stations > 1,] # so each station relates to a specific set of coordinates
stations2011[stations2011$numphotos > 1,] # there were a few instances where 2 photos were taken at the exact same location/station. This is fine. 
dim(stations2011) # 1336 different locations (3 locations had 2 photos taken)

photos2011 <- ddply(clean2011, .(STATION_NUM, Mussels),
                    summarize,
                    mean_lat=mean(PHOTO_LAT),
                    mean_lon=mean(PHOTO_LONG),
                    num_photos=length(unique(unid)))
summary(photos2011)

photos2011_summary <- ddply(.data=clean2011, .(STATION_NUM),
                         summarize,
                         Mussels = max(as.numeric(Mussels)),
                         NumPhotos = length(unique(unid)))
summary(photos2011_summary)

length(unique(photos2011$STATION_NUM[photos2011$Mussels %in% c("MusselReef", "Shells")])) #6 stations with Reef OR Shells
length(unique(photos2011$STATION_NUM[photos2011$Mussels %in% c("MusselReef")])) #1 stations with Reef
length(unique(photos2011$STATION_NUM[photos2011$Mussels %in% c("Shells")])) #6 stations with Shells

photos2011[photos2011$Mussels %in% c("MusselReef"),] # 9 photos of mussel reef
clean2011$unid[clean2011$Mussels %in% c("MusselReef")] # station 176, photos 719, 713, 714, 712, 711, 710, 705, 704, 703
# groundtruth2011[groundtruth2011$Mussels == "MusselReef",] 

require(ggplot2)
require(rgdal)
require(sp)
require(raster)
maritimes_sp <- readOGR("Y:/Maps/shp/Maritimes_UTM.shp")
maritimes_sp <- spTransform(maritimes_sp, CRS("+proj=longlat +datum=WGS84"))
maritimes_sp <- crop(maritimes_sp, extent(-67.35, -62.9, 43.35, 46.2))
maritimes <- fortify(maritimes_sp)

levels(photos2011$Mussels) <- c("0", "2", "1")
photos2011$Mussels <- factor(photos2011$Mussels, levels = c("0", "1", "2"))
photos2011$Mussels <- as.numeric(photos2011$Mussels)
photos2011_plot <- ddply(.data=photos2011, .(mean_lon, mean_lat),
                         summarize, 
                         Mussels = max(as.numeric(Mussels)))

photos2011_plot$Mussels <- as.factor(photos2011_plot$Mussels)
levels(photos2011_plot$Mussels) <- c("Absent", "Shells", "Reef")

# ggplot() + 
#   geom_polygon(data=maritimes, aes(long, lat, group=group), fill="darkgrey", colour="black") +
#   geom_point(data=photos2011_plot %>% arrange(Mussels), aes(mean_lon, mean_lat, colour=Mussels), size=3) + theme_bw() + theme(panel.grid=element_blank()) +
#   coord_map() + 
#   ggtitle("2011 Images") #+
# facet_wrap(~Mussels)

clean2011utm <- read.csv("clean2011_utm.csv", stringsAsFactors = F)
clean2011utm <- dplyr::select(clean2011utm, unid, POINT_X, POINT_Y)
clean2011 <- left_join(clean2011, clean2011utm)

clean2011$Mussels <- as.character(clean2011$Mussels)
clean2011$Mussels[is.na(clean2011$Mussels)] <- "0"
clean2011$Mussels <- as.factor(clean2011$Mussels)
levels(clean2011$Mussels) <- c("0", "2", "1")
clean2011$Mussels <- factor(clean2011$Mussels, levels = c("0", "1", "2"))
clean2011$Mussels <- as.numeric(clean2011$Mussels)

photos2011_tile <- ddply(.data=clean2011, .(STATION_NUM, POINT_X, POINT_Y),
                         summarize, 
                         Mussels = max(as.numeric(Mussels)),
                         NumPhotos = length(unique(unid)))

mapagg_2011 <- make.grid(x = photos2011_tile$POINT_X,
                         y = photos2011_tile$POINT_Y,
                         z = photos2011_tile$NumPhotos, 
                         byx = 10000, byy = 10000, 
                         xlim = c(186500, 385700), ylim = c(4885000, 5022000), 
                         fun = sum)
mapagg_2011 <- melt(mapagg_2011)

colnames(mapagg_2011) <- c("LongUTM", "LatUTM", "NumPhotos")

options(scipen=999)

png("photo distribution 2011.png", height=500, width=800, res=100)
ggplot() + 
  geom_tile(data=mapagg_2011[!is.na(mapagg_2011$NumPhotos),],aes(LongUTM,LatUTM,fill=NumPhotos))+
  geom_polygon(data=maritimes_UTM, aes(long, lat, group=group), fill="darkgrey", colour=NA) +
  scale_fill_gradient(name="Number of photos",guide="legend",low = "yellow", high = "red") + 
  theme_bw() + theme(panel.grid=element_blank()) + 
  coord_cartesian(xlim = c(175500, 426700), ylim = c(4854000, 5053000)) +
  ylab("Latitude") +
  xlab("Longitude") + 
  ggtitle("2011 imagery")
dev.off()

mapmuss_2011 <- make.grid(x = photos2011_tile$POINT_X,
                          y = photos2011_tile$POINT_Y,
                          z = photos2011_tile$Mussels, 
                          byx = 10000, byy = 10000, 
                          xlim = c(186500, 385700), ylim = c(4885000, 5022000), 
                          fun = max)
mapmuss_2011 <- melt(mapmuss_2011)

colnames(mapmuss_2011) <- c("LongUTM", "LatUTM", "Mussels")

options(scipen=999)

png("mussel distribution 2011.png", height=500, width=800, res=100)
ggplot() + 
  geom_tile(data=mapmuss_2011[!is.na(mapmuss_2011$Mussels),],aes(LongUTM,LatUTM,fill=as.factor(Mussels)))+
  geom_polygon(data=maritimes_UTM, aes(long, lat, group=group), fill="darkgrey", colour=NA) +
  scale_fill_manual(name="Mussel presence",guide="legend", breaks=c(1,2,3), values=c("yellow", "orange", "red"), labels=c("Absent", "Shells", "Reef")) + 
  theme_bw() + theme(panel.grid=element_blank()) + 
  coord_cartesian(xlim = c(175500, 426700), ylim = c(4854000, 5053000)) +
  ylab("Latitude") +
  xlab("Longitude") + 
  ggtitle("2011 imagery")
dev.off()

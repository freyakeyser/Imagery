
list.files(yfolder)

join2011 <- read.csv(paste0(yfolder, "/2011 CSV Format for R.csv"))
join2009 <- read.csv(paste0(yfolder, "/2009 CSV Format for R.csv"))

groundtruth <- read.csv(paste0(yfolder, "/Horse Mussel Groundtruthing.csv"))

View(join2011)

View(join2009)

View(groundtruth)
table(groundtruth$Mussels.)

groundtruth2009 <- groundtruth[groundtruth$Year==2009,]
groundtruth2011 <- groundtruth[groundtruth$Year==2011,]

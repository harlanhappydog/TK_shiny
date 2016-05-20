library(rgdal)
source('~/Documents/KahlilShiny/TakingRoot_Shiny1  May19thbackup/loaddata2.R', chdir = TRUE)
ls()
head(mydat1)
dim(mydat1)
sum(!is.na(mydat$kml))

mydat2<-(mydat1[!is.na(mydat1$kml),])
dim(mydat2)


head(mydat2)
mmm<-readRDS("~/Documents/KahlilShiny/TakingRoot_Shiny1  May19thbackup/superzip.rds")

mmm3<-mmm[1:dim(mydat2)[1],]
head(mmm3)

########################################
# download images:
#for(ii in 1:dim(mydat2)[1]){	

#	print(ii)
#	print(as.character(mydat2$link[ii]))
#tryCatch(
#	download.file(
#	url=paste("http://", as.character(mydat2$link[ii]), sep=""), paste("~/Documents/KahlilShiny/image_folder/jpg_",mydat2$P_Id[ii],".jpg",sep="")),  error=function(e)	print("oke"), warning=function(e){download.file(
#	url=paste("http://www.planvivo.org/wp-content/themes/vantage/images/projects/TakingRootLOGO.jpg"), paste("~/Documents/KahlilShiny/image_folder/jpg_",mydat2$P_Id[ii],".jpg",sep=""))})	
#}
#files <- dir('~/Documents/KahlilShiny/image_folder')
#length(files)
########################################

for(ii in 1:dim(mydat2)[1]){	
library(RCurl)
eximg<-url.exists(paste("http://", as.character(mydat2$link[ii]), sep=""))
if(eximg){
	mydat2$image[ii]<-paste("http://", as.character(mydat2$link[ii]), sep="")}
if(!eximg){mydat2$image[ii]<-paste("http://www.planvivo.org/wp-content/themes/vantage/images/projects/TakingRootLOGO.jpg")}
print(ii)
}

# download kml files:
for(ii in 1:dim(mydat2)[1]){
	if(!is.na(mydat2$kml[ii])){
	download.file(url=as.character(mydat2$kml[ii]), 
		paste("~/Documents/KahlilShiny/TakingRoot_Shiny1  May19thbackup/data/kml_folder/kml_",
		mydat2$P_Id[ii],".kml",sep=""))
		}
print(ii)
}






# Get list of all files
files <- dir('~/Documents/KahlilShiny/TakingRoot_Shiny1  May19thbackup/data/kml_folder')
length(files)
# Set up color index
cindex <- 1
ccc <- sample(colors(),length(files))
# loop over all files and read in lines
mynames<-rep("",length(files))
myarea<-rep(0,length(files))
mylastnames<-rep("",length(files))
coordsmat<-data.frame(files= files,lon=0,lat=0, area=0)
mycoords<-list()
i<-1
for(file in files){
    lines <- readLines(paste('~/Documents/KahlilShiny/TakingRoot_Shiny1  May19thbackup/data/kml_folder/',file,sep=''))
    lines2 <- lines[1]
    for(jj in 2:length(lines)){
        lines2 <- paste(lines2,lines[jj],sep='')
    }
    sql <- unlist(strsplit(lines2,'<coordinates>|</coordinates>'))[2]
sql2<-(strsplit(sql," "))[[1]]
coords<-t(matrix(as.numeric(unlist(strsplit(sql2,","))),2,))

# remove locations in the middle of the ocean:
if(min(abs(c(coords)))<10){print(i)
	print(file)
	coords<-coords[apply(coords,1,function(x) min(abs(x))>3),]
	print(coords)
	if(dim(coords)[1]==0){	coords<-cbind(-99,-99)}
	}
	colnames(coords)<-c("lon","lat")
coords<-data.frame(coords)
coords$planvivo<-unlist(strsplit(lines2,'Plan Vivo Number:</b> |</p><p>'))[5]
mycoords[[i]]<-coords
coordsmat[i,c("lon","lat")]<-colMeans(coords[,c("lon","lat")])
sql <- unlist(strsplit(lines2,'<p><b>Last Name:</b>|</p><p>'))[3]
sql2<-(strsplit(sql,"</b>"))[[1]][2]
lastnames<-sql2

sql <- as.numeric(unlist(strsplit(lines2,'<p><b>Area:</b>|m squared]]'))[2] )
area<-sql



sql <- unlist(strsplit(lines2,'<b>Name:</b>|</p><p>'))[3]
#sql2<-(strsplit(sql,"</b>"))[[1]][2]
names<-sql
myarea[i]<-round(area,2)
mylastnames[i]<-as.character(lastnames)
mynames[i]<-as.character(names)
i<-i+1
}
dim(coordsmat)

names(mycoords)<-c(paste(mydat2$P_Id))
mycoords



mmm3$households<-mydat2$link
mmm3$households<-mydat2$image

mmm3$county <-mydat2$Id
mmm3$city.y<-mydat2$P_Id
mmm3$state.y<-mydat2$nombre_de_productor

mmm3$longitude<-coordsmat$lon
mmm3$latitude <-coordsmat$lat
mmm3$city.x <-mynames
mmm3$state.x <-mylastnames
mmm3$adultpop <-mydat2$System


for(jj in 1:length(mycoords)){
mycoords[[jj]][,c("planvivo_plot")]<-	names(mycoords)[jj]
mycoords[[jj]]$zipcode <-mmm3[mmm3$city.y==names(mycoords)[jj],]$zipcode
}

#mmm3$centile<-centile
head(mmm3)
#mmm3original<-mmm3
#mmm3<-mmm3original
saveRDS(mmm3,"~/Documents/KahlilShiny/TakingRoot_Shiny1  May19thbackup/ShinyFolder/data/superzip2.rds")

saveRDS(mycoords,"~/Documents/KahlilShiny/TakingRoot_Shiny1  May19thbackup/ShinyFolder/data/coordsshps.rds")











#Need to make meta data for each table and explain what it is. SEE: Metadata.xlsx 


#Reference for this code:  http://www.r-bloggers.com/getting-started-with-postgresql-in-r/

rm(list=ls())
#file.choose()

#!!!!!!!!! Enter Year of Annual Report (YAR)

YAR <- 2016

# ATTENTION:  You must:  install.packages("RPostgreSQL")
require("RPostgreSQL")
#Documentation for this plugin:  https://cran.r-project.org/web/packages/RPostgreSQL/RPostgreSQL.pdf

#### CREATE A CONNECTION
# enter in password here
pw <- {  "tree43pgs"}
usr <- {  "david"   }  #we can make a new user at some point.  this is read only access.  newton has access to a login with read/write access

# loads the PostgreSQL driver
drv <- dbDriver("PostgreSQL")
# creates a connection to the postgres database
# note that "con" will be used later in each connection to the database
con <- dbConnect(drv, dbname = "SCPIMS",
                 host = "192.241.213.120", port = 5432,
                 user = usr, password = pw)
rm(pw) # removes the password from memory
rm(usr) #remove the username from memory

# check for the table adelantados
dbExistsTable(con, "adelantados")
# IF TRUE then the connection is working to PGS


#List of Tables
dbListTables(con)

###Tables of interest:
  ##Producer Information
    #informacion_de_productor - Producer Information (not year specific)
      #documentos_pv - PV Documentation Information (year specific)
        #parcels - Parcel information
    #pagos - PES to farmers
    #adelantados - Loans to Farmers
  ##Monitoring Information
    #monitoreo - Parcel level
    #monitoreo_ao - Parcel Level by year
    #monitoreo_puntos - Point level by year
    #Monitoring_tree - Tree Level by year

#Load a tables

parcels <- dbGetQuery(con, "SELECT * from parcels")
monitoreo <- dbGetQuery(con, "SELECT * from monitoreo")

monitoreo_puntos<-dbGetQuery(con, "SELECT * from monitoreo_puntos")

AdvancePayments <- dbGetQuery(con, "SELECT * from adelantados")  #Replace adelantados for another table name
FarmerInfo <- dbGetQuery(con, "SELECT * from informacion_de_productor")  
ParcelInfo <- dbGetQuery(con, "SELECT * from parcels") 
pagos<- dbGetQuery(con, "SELECT * from pagos")
FarmerYearInfo <- dbGetQuery(con, "SELECT * from documentos_pv") 

informacion_de_productor <-dbGetQuery(con, "SELECT * from informacion_de_productor")

documentos_pv_fotos <-dbGetQuery(con, "SELECT * from documentos_pv_fotos")

informacion_de_productor_fotos<-dbGetQuery(con, "SELECT * from informacion_de_productor_fotos")
informacion_de_productor_fotos$link

informacion_de_productor_fotos[informacion_de_productor_fotos $field=="productor_foto",]$link


informacion_de_productor_fotos <-informacion_de_productor_fotos[informacion_de_productor_fotos$field=="productor_foto",]

photos<-data.frame(Id=apply(cbind(1:length(informacion_de_productor_fotos$caption)),1,function(i) strsplit(informacion_de_productor_fotos$caption, " ")[[i]][1]),informacion_de_productor_fotos)


pp<-(ParcelInfo[,c("parcel_id","un_par","year_of_planting_parcela")])

head(monitoreo_puntos)


ppp<-merge(pp, monitoreo_puntos, by.x="parcel_id",by.y= "parcel_id")

head(ppp)

head(photos)
####  creating mydat ####
mydat0<-data.frame(substr(ParcelInfo$un_par,1,8),ParcelInfo$un_par,ParcelInfo$tech_spec, ParcelInfo$year_of_planting_parcela, ParcelInfo$url_kml)
names(mydat0)<-c("Id","P_Id","System", "Year","kml")

mydat00<-merge(mydat0, informacion_de_productor[,c("nombre_de_productor","numero_de_plan_vivo", "entry_year")], by.y="numero_de_plan_vivo", by.x="Id", all.x=TRUE)

mydat000<-(mydat00)

mydat<-merge(mydat000, photos,by="Id",all.x=TRUE)

# replace missing photos urls with logo
mydat[!is.na(mydat$link),]
mydat[is.na(mydat$link),]$link<-"www.planvivo.org/wp-content/themes/vantage/images/projects/TakingRootLOGO.jpg"


mydat1<-mydat[,c("P_Id", "Id","System" ,"Year","kml",                                "nombre_de_productor" ,"entry_year","link")]


head(mydat)
head(ppp)



mydat001<-merge(mydat,ppp,by.x="P_Id",by.y="un_par")




#xy<-data.frame(X=mydat1$utm_este_parcela_monitoreo_puntos, Y=mydat1$utm_norte_parcela_monitoreo_puntos)
#coordinates(xy) <- c("X", "Y")
#proj4string(xy) <- CRS("+proj=utm +zone=51 ellps=WGS84")  
#ll<-spTransform(xy,CRS("+proj=longlat"))
#head(ll)

#mydat1$lat1<-ll$X
#mydat1$lon1<-ll$Y
#head(mydat1)

#colnames(mydat1)
#mydat11<-mydat1[,c("P_Id", "Id","System" ,"Year","kml",                                "nombre_de_productor" ,"entry_year","link","utm_este_parcela_monitoreo_puntos" ,"utm_norte_parcela_monitoreo_puntos","lat1","lon1")]
#head(mydat11)
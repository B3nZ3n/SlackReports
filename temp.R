
library(tidyr)
library(dplyr)
library(data.table)
library(lubridate)
library(dplyr)
library(ggplot2)
library(plotly)
library(ggalluvial)
library(forcats)
source(file = "services/ETL.R", encoding = "utf-8")

#unzipFiles()

allUsers <- fromJSON("input/users.json" ,flatten=TRUE) %>%
  as.data.frame()

keeps <- c("id", "name", "real_name", "color")

allUsers <- allUsers[!allUsers$deleted & !allUsers$is_bot ,keeps]

allUsers$color <- paste0("#",allUsers$color)
summary(allUsers)

colors <- allUsers[!allUsers$color == "#NA",c("name","color")]
plotColors <- colors$color
names(plotColors) <- colors$name

files <- list.files(path = "input/general", full.names = TRUE) 
files <- files[order(files)]

length(files)

##sampling last 365 days##
#files <- tail(files,365)

extractFileContent <- function(filename){
  
  messages <- fromJSON(filename,flatten = TRUE)
  
  messages %>% 
    select(one_of(c("client_msg_id","type","text","user","ts","reply_users","reactions"))) %>%
    as.data.frame() 
    
  
}


allMessages <- sapply(files, FUN=extractFileContent)

allMessages <- rbindlist(allMessages, fill=TRUE)


allMessages$ts = as_datetime(as.integer(allMessages$ts))
allMessages$username <- with(allUsers, name[match(allMessages$user, id)])

allMessages <- allMessages[allMessages$user %in% allUsers$id,]


head(allMessages)



msgpernickperhour <- count(allMessages, username , hour(ts),format(ts, "%U"))
names(msgpernickperhour) <- c("unick", "hour", "weeknumber", "n")
  






threads <- allMessages[!allMessages$reply_users == "NULL",c("user","reply_users")]
threads <- tidyr::unnest(threads, cols = reply_users)




threads %>% group_by(user,reply_users) %>%
  summarise(count_replies = n())  -> threads

threads$user <- with(allUsers, name[match(threads$user, id)])
threads$reply_users <- with(allUsers, name[match(threads$reply_users, id)])
threads <- threads[threads$user %in% c("b3nz3n","logs","qn7o","roux","rylou","tony","vv","woookash"),]
threads <- threads[threads$count_replies > 5,]


ggplot(threads,
       aes(axis1 = user,
           axis2 = reply_users,
           y = count_replies)) +
  
  geom_alluvium(aes(fill = user),curve_type = "sigmoid",width = 1/10, alpha=0.7) +
  
  geom_stratum(width = 1/10) +
  
  geom_text(stat = "stratum", 
            aes(label= paste(after_stat(stratum))))+
  
  scale_x_discrete(limits = c("user", "reply_users"),
                   expand = c(.1, .1)) +
  
  scale_fill_manual(values = plotColors )+
  ggtitle("Nombre de messages envoyés par \"reply_users\" dans un thread créé par \"user\"")+
  theme(legend.position = "none")


ggplot(threads,
       aes(x = username,
           y = reply_users,
           fill = count_replies)) +
  geom_tile()+
  ggtitle("Nombre de messages envoyés par \"reply_users\" dans un thread créé par \"user\"")

  
  
reactions <- allMessages[!allMessages$reactions == "NULL",c("user","reactions")]
reactions <- tidyr::unnest(reactions, cols = reactions)
reactions <- reactions[,c("user","name","count")]

reactions %>% group_by(user,name) %>%
  summarise(count_reaction = sum(count))  -> reactions

reactions$user <- with(allUsers, name[match(reactions$user, id)])

reactions %>% group_by(name) %>% summarise(sum(count_reaction)) %>% top_n(n = 10) -> top10emojii


reactions <- reactions[reactions$name %in% top10emojii$name,]



ggplot(data = reactions, aes(name, count_reaction, fill = user)) +
  geom_bar(stat ='identity') +
  scale_fill_manual(values = plotColors) +
  ggtitle("Emojii usage per user") +
  xlab("emojii")+
  ylab("Number of uses")+
  theme(axis.text.x = element_text(angle = -90, hjust = 0))







jokeScores <- rev(c("zero","one","two","three","four","five","six","seven","height","nine","keycap_ten"))

jokeColors <- rev(c("#FF0000","#dd776e","#e2886c","#e79a69","#ecac67","#e9b861","#f5ce62","#d4c86a","#b0be6e","#94bd77","#73b87e"))
names(jokeColors) <- jokeScores

reactions <- allMessages[!allMessages$reactions == "NULL",c("user","reactions")]
reactions <- tidyr::unnest(reactions, cols = reactions)
reactions <- reactions[,c("user","name","count")]

reactions %>% group_by(user,name) %>%
  summarise(count_reaction = sum(count))  -> reactions

reactions$user <- with(allUsers, name[match(reactions$user, id)])

reactions <- reactions[reactions$name %in% jokeScores,]


reactions$name <- ordered(reactions$name, levels=names(jokeColors))



ggplot(data = reactions, aes(x=user, y=count_reaction, fill = name,order=name)) +
  geom_bar(stat ='identity') +
  scale_fill_manual("",values=jokeColors)+
  ggtitle("Les plus rigolos? depuis 2015") +
  xlab("username")+
  ylab("score")+
  theme(axis.text.x = element_text(angle = -90, hjust = 0))


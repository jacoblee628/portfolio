import sys
import pandas as pd

#read in csv file
df = pd.read_csv('pubg-match-deaths/deaths/kill_match_stats_final_'+str(i)+'.csv')
#filter out stats from other maps
df = df[df.map=='ERANGEL']
#filter out natural deaths (falling, got punched, grenade, mine, bluezone etc)
df = df[((df.victim_position_x)>0) & ((df.victim_position_y)>0)]
df = df[((df.killer_position_x)>0) & ((df.killer_position_y)>0)]
#drop the irrelevant columns
df = df.drop(['killed_by', 'killer_name', 'killer_placement', 'killer_position_x','killer_position_y', 'map', 'match_id', 'time', 'victim_name', 'victim_placement'],axis=1)
#df = df.drop(['killed_by', 'killer_name', 'killer_placement', 'map', 'match_id', 'time', 'victim_name', 'victim_placement','victim_position_x', 'victim_position_y'],axis=1)
#only take the first 2 million rows of data
df = df.take(2000000);
df.to_csv('twoMilVic''.csv',index=False,header=False);
print ("DONE")

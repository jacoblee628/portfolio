import sys
import re
from pyspark import SparkContext
from pyspark import SparkConf

# load data
devicedata = sc.textFile("file:/home/cloudera/training_materials/dev1/data/devicestatus.txt")
# split the text by each line(=record)
byRecord = devicedata.flatMap(lambda line: line.split("\n"))
# split each line with one of the three delimiters: ',' '/' '|'
parsed = byRecord.filter(lambda line: re.split(',|/|\|',line))

# extracting killer_position_x, killer_position_y, killer_name, killer_placement, map, match_id, time, killed_by
ext_killer = parsed.map(lambda line: re.split(',|/|\|',line)[3]+','+re.split(',|/|\|',line)[4]+','+re.split(',|/|\|',line)[1]+','+re.split(',|/|\|',line)[2]+','+re.split(',|/|\|',line)[5]+','+re.split(',|/|\|',line)[6]+','+re.split(',|/|\|',line)[7]+','+re.split(',|/|\|',line)[0])
# filter out records that have x and y of 0
nonZero_killer = ext_killer.filter(lambda line: line.split(',')[0]!='0' and line.split(',')[1]!='0')

# extracting victim_position_x, victim_position_y, victim_name, victim_placement, map, match_id, time, killed_by
ext_victim = parsed.map(lambda line: re.split(',|/|\|',line)[10]+','+re.split(',|/|\|',line)[11]+','+re.split(',|/|\|',line)[8]+','+re.split(',|/|\|',line)[9]+','+re.split(',|/|\|',line)[5]+','+re.split(',|/|\|',line)[6]+','+re.split(',|/|\|',line)[7]+','+re.split(',|/|\|',line)[0])
# filter out records that have x and y of 0
nonZero_victim = ext_victim.filter(lambda line: line.split(',')[0]!='0' and line.split(',')[1]!='0')


# save data
nonZero_killer.saveAsTextFile("hdfs://localhost/loudacre/devicestatus_etl/pubg_killerdata")

# save data
nonZero_victim.saveAsTextFile("hdfs://localhost/loudacre/devicestatus_etl/pubg_victimdata")



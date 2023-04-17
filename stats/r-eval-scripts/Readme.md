# Evaluating Scavetool's output

## Scavetool CSV format

| run                                | type    | module | name | attrname                                           | attrvalue                                                                                 | value |
|------------------------------------|---------|--------|------|----------------------------------------------------|-------------------------------------------------------------------------------------------|-------|
| Evaluation-14-20230416-19:38:40-76 | runattr |        |      | configname                                         | Evaluation                                                                                |       |
| Evaluation-14-20230416-19:38:40-76 | runattr |        |      | datetime                                           | 20230416-19:38:40                                                                         |       |
| Evaluation-14-20230416-19:38:40-76 | runattr |        |      | experiment                                         | Evaluation                                                                                |       |
| Evaluation-14-20230416-19:38:40-76 | runattr |        |      | inifile                                            | omnetpp.ini                                                                               |       |
| Evaluation-14-20230416-19:38:40-76 | runattr |        |      | iterationvars                                      | $NumberOfDrones=0, $NumberOfVehicles=10, $AccidentProbability=0.2                         |       |
| Evaluation-14-20230416-19:38:40-76 | runattr |        |      | repetition                                         | 14                                                                                        |       |
|                                    |         |        |      |                                                    |                                                                                           |       |
| Evaluation-16-20230416-19:38:40-82 | runattr |        |      | repetition                                         | 16                                                                                        |       |
| Evaluation-185-20230416-19:39:08-933| scalar | DronesScenario.node[5].appl | totalTimeInJam | | | 188 |
| Evaluation-16-20230416-19:38:40-82 |itervar|||NumberOfDrones|10|


## 1. Create Run-Repetition association

*Code*

~~~sql
select Run, Attrvalue as Repetition from scalars where Type == 'runattr' and Attrname == 'repetition'
~~~

*Output (first rows)*:

|                                   run | Repetition    |
|---------------------------------------|---------------|
| Evaluation-14-20230416-19:38:40-76    |14             |
| Evaluation-16-20230416-19:38:40-82    |16             |
| Evaluation-15-20230416-19:38:40-80    |15             |
| Evaluation-17-20230416-19:38:40-83    |17             |
| Evaluation-1-20230416-19:38:40-49     |1              |
| Evaluation-0-20230416-19:38:40-50     |0              |
| Evaluation-10-20230416-19:38:40-68    | 10            |
| Evaluation-11-20230416-19:38:40-69    |11             |
| Evaluation-335-20230416-19:39:59-1719 |35             |
| Evaluation-12-20230416-19:38:40-72    |12             |


## 2. Get iteration variables



*Code: *

~~~sql
select distinct Attrname from scalars where Type == 'itervar'
~~~

*Output (full):*

|             attrname |
|----------------------|
| AccidentProbability  |
|      NumberOfDrones  |
|    NumberOfVehicles  |

## 3. Get jammed vehicles in all runs

*Code: *

~~~sql
select scalars.Run, scalars.Module from scalars where Name == 'totalTimeInJam' and Value > 0
~~~

*Output (first rows):*

|                                   run | module    |
|---------------------------------------|---------------|
|       Evaluation-0-20230416-19:38:40-50 | DronesScenario.node[3].appl |
|       Evaluation-0-20230416-19:38:40-50 | DronesScenario.node[0].appl |
|       Evaluation-0-20230416-19:38:40-50 | DronesScenario.node[7].appl |
|       Evaluation-0-20230416-19:38:40-50 | DronesScenario.node[10].appl|
|       Evaluation-0-20230416-19:38:40-50 | DronesScenario.node[11].appl|
|       Evaluation-1-20230416-19:38:40-49 | DronesScenario.node[4].appl |
|       Evaluation-1-20230416-19:38:40-49 | DronesScenario.node[2].appl |
|       Evaluation-1-20230416-19:38:40-49 | DronesScenario.node[10].appl|
|       Evaluation-1-20230416-19:38:40-49 | DronesScenario.node[11].appl|
|     Evaluation-10-20230416-19:38:40-68  | DronesScenario.node[5].appl |
|     Evaluation-10-20230416-19:38:40-68  | DronesScenario.node[7].appl |

## 4. Get total number of jammed vehicles in all runs

*Code: *

~~~sql
select scalars.Run, scalars.Module from scalars where Name == 'totalTimeInJam' and Value > 0
~~~

*Output (first rows):*



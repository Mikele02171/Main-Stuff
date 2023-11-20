// CSE3BDC/CSE5BDC Lab 05 - Processing Big Data with Spark
/*******************************************************************************
 * Exercise 1
 * Write code that first finds the square root of each number in an RDD and then
 * sums all the square roots together.
 */
// TODO: Write your code here
val someNumbers = sc.parallelize(1 to 1000)
val result = someNumbers.map(math.sqrt(_)).sum()// TODO
// TODO: Copy and paste the result here

//result: Double = 21097.455887480734



/*******************************************************************************
 * Exercise 2
 * Sum up the total salary for each occupation and then report the output in
 * ascending order according to occupation - in *one line* of code.
 */
val people = sc.parallelize(Array(("Jane", "student", 1000),
                                  ("Peter", "doctor", 100000),
                                  ("Mary", "doctor", 200000),
                                  ("Michael", "student", 1000)))
val result = people.map(p => (p._2, p._3)).reduceByKey(_ + _).sortBy(_._2, true)// TODO
result.collect
// TODO: Copy and paste the result here
// res0: Array[(String,Int)] = Array((student,1100),(doctor,300000))



/*******************************************************************************
 * Exercise 3
 * Use the map method to create a new pair RDD where the key is "native-country"
 * and the value is age. Use the filter function to remove records with missing
 * data.
 */
// TODO: Write your code here
val countryAge = censusSplit.map(r => (r(13), r(0).toInt)).filter(_._1 != "?")// TODO
println(countryAge.count()) // Does this equal 31978? Yes
println(countryAge)
// TODO: Copy and paste the result here
//31978




/*******************************************************************************
 * Exercise 4
 * Find the age of the oldest person from each country so the resulting RDD
 * should contain one (country, age) pair per country. 
 */
// TODO: Write your code here
val oldestPerCountry = countryAge.distinct.reduceByKey(math.max)// TODO
// TODO: Copy and paste the result here
//scala> oldestPerCountry.collect
//res17: Array[(String, Int)] = Array((Hungary,81), (Portugal,78), 
//(United-States,90), (Canada,80), (Jamaica,66), (Japan,61), (Honduras,58), 
//(Hong,60), (Peru,69), (Cambodia,65), (El-Salvador,79), (Vietnam,73), 
//(Iran,63), (Columbia,75), (Taiwan,61), (Scotland,62), (Yugoslavia,66), 
//(Poland,85), (Outlying-US(Guam-USVI-etc),63), (South,90), (Mexico,81), 
//(Ecuador,90), (Laos,56), (Nicaragua,67), (China,75), (Italy,77), (Greece,65), 
//(France,64), (Germany,74), (Puerto-Rico,90), (Holand-Netherlands,32), (Cuba,82), 
//(Haiti,63), (Ireland,68), (Dominican-Republic,78), (Philippines,90), (Guatemala,66),
// (Thailand,55), (Trinadad&Tobago,61), (India,61), (England,90))




/*******************************************************************************
 * Exercise 5
 * Output the top 7 countries in terms of having the oldest person. The output
 * should again be the country followed by the age of the oldest person.
 */
// TODO: Write your code here
// TODO: Copy and paste the result here
oldestPerCountry.sortBy(_._2, false).take(7)

//scala> oldestPerCountry.sortBy(_._2, false).take(7)
//res18: Array[(String, Int)] = Array((United-States,90), (South,90), (Ecuador,90), 
//(Puerto-Rico,90), (Philippines,90), (England,90), (Poland,85))
//



/*******************************************************************************
 * Exercise 6
 * Output the top 7 countries in terms of having the oldest person. The output
 * should again be the country followed by the age of the oldest person.
 */
// TODO: Write your code here
val allPeople = censusSplit.map(r => (r(13), r(3), r(6), r(9)))// TODO: Step 1
allPeople.take(5).foreach(println)
// TODO: Copy and paste the result here
//scala> allPeople.take(5).foreach(println)
//(United-States,Bachelors,Adm-clerical,Male)
//(United-States,Bachelors,Exec-managerial,Male)
//(United-States,HS-grad,Handlers-cleaners,Male)
//(United-States,11th,Handlers-cleaners,Male)
//(Cuba,Bachelors,Prof-specialty,Female)





val filteredPeople = allPeople.filter(_._3 != "?") // TODO: Step 2
filteredPeople.count // Does this equal 30718? Yes
// TODO: Copy and paste the result here
//scala> filteredPeople.count 
//res20: Long = 30718


val canadians = filteredPeople.filter(_._1 == "Canada")// TODO: Step 3
val americans = filteredPeople.filter(_._1 == "United-States") // TODO: Step 3
canadians.count // Does this equal 107?
//scala> canadians.count
//res9: Long = 107


americans.count // Does this equal 27504?
// TODO: Copy and paste the result here
//scala> americans.count
//res11: Long = 27504



val repCandidates = canadians.map(r => (r._3, r)).join(americans.map(r => (r._3, r))).values // TODO: Step 4
repCandidates.count // Does this equal 325711?
// TODO: Copy and paste the result here
//scala> repCandidates.count 
//res12: Long = 325711


val includingDoctorate = repCandidates.filter(r => r._1._2 == "Doctorate" || r._2._2 == "Doctorate")// TODO: Step 5
includingDoctorate.count // Does this equal 31110?
// TODO: Copy and paste the result here
//scala> includingDoctorate.count 
//res13: Long = 31110



/*
 * SCRATCHPAD
 * Play around, and save any helpful Scala/Spark commands below this section
 */

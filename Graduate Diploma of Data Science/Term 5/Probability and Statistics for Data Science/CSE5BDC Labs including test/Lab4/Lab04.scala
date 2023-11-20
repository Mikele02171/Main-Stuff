// CSE3BDC/CSE5BDC Lab 04 - Programming in Scala
/*******************************************************************************
 * Exercise 1
 * Declare an Int-type constant, setting it's value to your age as a Long
 * (i.e. append the L character to the number). Your age is clearly small
 * enough to fit into an Int. Does Scala implicitly convert from a Long to an
 * Int when the value is small enough to convert without losing information?
 */
// TODO: Write your code here
var name = "Michael Le"
name = 25

// TODO: Answer the question; give justification.

// Since name is a String it cannot store an Int, hence type mismatch.



/*******************************************************************************
 * Exercise 2
 * Use the zip method to write code which calculates the dot product
 * of two vectors.
 */
val u = List(2, 5, 3)
val v = List(4, 3, 7)
val dot = u.zip(v).map(t => t._1 * t._2).reduce(_ + _) //TODO

// TODO: Copy and paste the result here
print(dot)



/*******************************************************************************
 * Exercise 3
 * Write a function that returns the character at index n of a given word if
 * the word is long enough - otherwise return '-'.
 */
def extract(word: String, n: Int) : Char = {
    if(n<word.length){
        word(n)
        } else {
           '_'
    }
  // TODO: Finish defining this function
}

val names = List("Peter", "John", "Mary", "Henry")
val result = names.map(extract(_,4))
// TODO: Copy and paste the result here
print(names)
print(result)




/*******************************************************************************
 * Exercise 4
 * Write a function which prints the maximum value in a sequence.
 */
def find_max(sequence: Seq[Int]) : Int = {
    // TODO: Finish defining this function
    sequence.reduce((a,b)=>{
        if(a>b){
            a
        } else {
            b
        }
    })

}

// Less verbose way
def find_max(sequence:Seq[Int]) : Int = {
  sequence.reduce((x, y) => Math.max(x, y))
}
// Even less verbose way
def find_max(sequence:Seq[Int]) : Int = {
  sequence.reduce(Math.max)
}
// The correct way to do it in Scala, but not what we asked you to do:
def find_max(sequence:Seq[Int]) : Int = {
  sequence.max
}
// All answers are acceptable

val numberList = List(4, 7, 2, 1)
find_max(numberList)
// TODO: Copy and paste the result here

val numberArray = Array(4, 7, 2, 1)
find_max(numberArray)
// TODO: Copy and paste the result here





/*******************************************************************************
 * Exercise 5
 * Write a function which, when given two integer sequences, returns
 * a List of the numbers which appear at the same position in both sequences.
 */
def matchedNumbers(a:Seq[Any], b:Seq[Any]) : Any = {
    // TODO: Finish defining this function.
  a.zip(b).filter(x => x._1 == x._2).map(_._1)
}

val list1 = List(1,2,3,10)
val list2 = List(3,2,1,10)
val mn = matchedNumbers(list1, list2)
// TODO: Copy and paste the result here

print(mn)

/*******************************************************************************
 * Exercise 6
 * Write a function which, when given two integer sequences, returns
 * a List of the numbers which appear at the same position in both sequences.
 */

def eligibility(person:(String, Int, String)) : Boolean = {
   // TODO: Finish defining this function
  person match {
    case (name:String, age:Int, gender:String) if gender == "female" && age >= 13 =>
      println(name + " is too old and not male")
      false
    case (name:String, _, gender:String) if gender == "female" =>
      println(name + " is not male")
      false
    case (name:String, age:Int, _) if age >= 13 =>
      println(name + " is too old")
      false
    case _ =>
      true
  }
}

val people = List(("Harry", 15, "male"), ("Peter", 10, "male"),
                  ("Michele", 20, "female"), ("Bruce", 12, "male"),
                  ("Mary", 2, "female"), ("Max", 22, "male"))
val allowedEntry = people.filter(eligibility(_))
// TODO: Copy and paste the result here

print(pepole)
// TODO: Copy and paste the result here

print(allowedEntry)


/*
 * SCRATCHPAD
 * Play around, and save any helpful Scala commands below this section
 */

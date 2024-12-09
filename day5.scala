import scala.io.Source
import scala.collection.mutable

def check(rules_map: mutable.Map[Int, mutable.Set[Int]], forbidden_vals: mutable
.Set[Int], v: Int): Boolean =
  forbidden_vals ++= rules_map.getOrElse(v, Set())
  !forbidden_vals.contains(v)

def gatherRules(line: String, rules_map: mutable.Map[Int, mutable
.Set[Int]]) =
  val (key, value) = line.split('|') match {
    case Array(a, b) => (a.toInt, b.toInt)
  }
  rules_map.getOrElseUpdate(key, mutable.Set()) += value

def getMiddleValueIfCorrect(values: Array[Int], rules_map: mutable.Map[Int,
  mutable
  .Set[Int]]) =
  val forbidden_vals: mutable.Set[Int] = mutable.Set()
  val isCorrect = values.reverse.map(v => check(rules_map,
      forbidden_vals, v))
    .forall(identity)

  if isCorrect then
    Some(values(values.length / 2))
  else
    None

@main
def main(): Unit =
  val lines = Source.fromFile("./day5.txt")
    .getLines()

  val rules_map: mutable.Map[Int, mutable.Set[Int]] = mutable.Map.empty
  var correct_total = 0
  var incorrent_total = 0

  for line <- lines do
    if line.contains('|') then
      gatherRules(line, rules_map)
    if line.contains(',') then
      var values: Array[Int] = line.split(',').map(v => v.toInt)
      getMiddleValueIfCorrect(values, rules_map) match {
        case Some(value) => correct_total += value
        case None => {
          var constr_for_prev_numbers: mutable.Map[Int, Int] = mutable.Map.empty
          var i = values.length - 1
          while (i > -1) {
            val v = values(i)
            rules_map.get(v) match {
              case None => {}
              case Some(constr_for_current_number) => constr_for_current_number.foreach {
                current_constr_number =>
                  if (!constr_for_prev_numbers.contains(current_constr_number))
                  then
                    constr_for_prev_numbers += (current_constr_number, i)
              }
            }
            if (constr_for_prev_numbers.contains(v)) {
              val insert_pos = constr_for_prev_numbers(v)
              values = (values.take(i) ++ values.drop(i + 1)).patch(insert_pos, Seq(v), 0)
              // NOTE: it is possible to not go all the way back but I
              // just want to check if the concept is correct
              i = values.length
              constr_for_prev_numbers.clear()
            }
            i -= 1
          }
          incorrent_total += values(values.length / 2)
        }
      }

  println(s"Incorrect total: ${incorrent_total}")
  println(s"Correct total: ${correct_total}")


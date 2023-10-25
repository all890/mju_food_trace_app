
class BuddhistYearConverter {

  String convertDateTimeToBuddhistDate (DateTime? dateTime) {
    String day = dateTime!.day.toString();
    String month = dateTime.month.toString();
    String year = dateTime.year.toString();
    switch (month) {
      case "1" : month = "มกราคม"; break;
      case "2" : month = "กุมภาพันธ์"; break;
      case "3" : month = "มีนาคม"; break;
      case "4" : month = "เมษายน"; break;
      case "5" : month = "พฤษภาคม"; break;
      case "6" : month = "มิถุนายน"; break;
      case "7" : month = "กรกฎาคม"; break;
      case "8" : month = "สิงหาคม"; break;
      case "9" : month = "กันยายน"; break;
      case "10" : month = "ตุลาคม"; break;
      case "11" : month = "พฤศจิกายน"; break;
      case "12" : month = "ธันวาคม"; break;
    }
    return "${day + " " + month + " " + (int.parse(year) + 543).toString()}";
  }

}
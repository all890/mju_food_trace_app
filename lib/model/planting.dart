
import 'farmer.dart';
import 'farmer_certificate.dart';

class Planting {

  String? plantingId;
  String? plantName;
  DateTime? plantDate;
  String? plantingImg;
  String? bioextract;
  DateTime? approxHarvDate;
  String? plantingMethod;
  double? netQuantity;
  String? netQuantityUnit;
  double? squareMeters;
  double? squareYards;
  double? rai;
  String? ptPrevBlockHash;
  String? ptCurrBlockHash;

  FarmerCertificate? farmerCertificate;

  Planting({
    this.plantingId,
    this.plantName,
    this.plantDate,
    this.plantingImg,
    this.bioextract,
    this.approxHarvDate,
    this.plantingMethod,
    this.netQuantity,
    this.netQuantityUnit,
    this.squareMeters,
    this.squareYards,
    this.rai,
    this.ptPrevBlockHash,
    this.ptCurrBlockHash,
    this.farmerCertificate,
  });

  Map<String, dynamic> fromPlantingToJson() {
    return <String, dynamic>{
      'plantingId': plantingId,
      'plantName': plantName,
      'plantDate': plantDate?.toIso8601String(),
      'plantingImg': plantingImg,
      'bioextract': bioextract,
      'approxHarvDate': approxHarvDate?.toIso8601String(),
      'plantingMethod': plantingMethod,
      'netQuantity': netQuantity,
      'netQuantityUnit': netQuantityUnit,
      'squareMeters': squareMeters,
      'squareYards': squareYards,
      'rai': rai,
      'ptPrevBlockHash': ptPrevBlockHash,
      'ptCurrBlockHash': ptCurrBlockHash,
      'farmerCertificate': farmerCertificate?.fromFarmerCertificateToJson(),
    };
  }

  factory Planting.fromJsonToPlanting(Map<String, dynamic> json) {

    
    return Planting(
      plantingId: json["plantingId"],
      plantName: json["plantName"],
      plantDate: DateTime.parse(json["plantDate"]).toLocal(),
      plantingImg: json["plantingImg"],
      bioextract: json["bioextract"],
      approxHarvDate:DateTime.parse(json["approxHarvDate"]).toLocal(),
      plantingMethod: json["plantingMethod"],
      netQuantity: json["netQuantity"],
      netQuantityUnit: json["netQuantityUnit"],
      squareMeters: json["squareMeters"],
      squareYards: json["squareYards"],
      rai: json["rai"],
      ptPrevBlockHash: json["ptPrevBlockHash"],
      ptCurrBlockHash: json["ptCurrBlockHash"],
      farmerCertificate: FarmerCertificate.fromJsonToFarmerCertificate(json["farmerCertificate"])
    );
  }

}

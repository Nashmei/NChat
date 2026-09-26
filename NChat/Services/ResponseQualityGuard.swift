import Foundation

enum ResponseQualityGuard {
 static func hasCorruptedUnicode(_ text:String)->Bool {
  text.unicodeScalars.contains{scalar in
   scalar.value == 0xFFFD || scalar.value == 0x0000
  }
 }

 static func isPredominantlyArabic(_ text:String)->Bool {
  var arabic=0
  var latin=0
  var insideFence=false
  for line in text.components(separatedBy:"\n"){
   if line.trimmingCharacters(in:.whitespaces).hasPrefix("```"){insideFence.toggle();continue}
   if insideFence{continue}
   for scalar in line.unicodeScalars {
    switch scalar.value {
    case 0x0600...0x06FF,0x0750...0x077F,0x08A0...0x08FF: arabic += 1
    case 0x0041...0x005A,0x0061...0x007A: latin += 1
    default: break
    }
   }
  }
  return arabic > 0 && arabic >= latin
 }

 static func validate(_ text:String,expectedArabic:Bool)throws {
  if hasCorruptedUnicode(text){throw QualityError.corruptedUnicode}
  if expectedArabic,!isPredominantlyArabic(text){throw QualityError.languageMismatch}
 }

 enum QualityError:LocalizedError {
  case corruptedUnicode,languageMismatch
  var errorDescription:String? {
   switch self {
   case .corruptedUnicode:return "The model returned corrupted Unicode. Try again or choose another verified model."
   case .languageMismatch:return "The model did not follow the Arabic language policy. Regenerate or choose another verified model."
   }
  }
 }
}

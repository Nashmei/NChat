import SwiftUI

struct RoyalHomeView: View {
    @EnvironmentObject var game: CrownStore
    @State private var floatKing = false

    var body: some View {
        ZStack {
            RoyalWorldBackground()

            VStack(spacing:0) {
                TopCurrencyBar().environmentObject(game)
                    .padding(.top,6)

                CrownLogo()
                    .padding(.top,12)

                Spacer(minLength:4)

                ZStack(alignment:.bottom) {
                    RoyalKing()
                        .scaleEffect(0.82)
                        .offset(y:floatKing ? -5:2)
                        .animation(.easeInOut(duration:1.7).repeatForever(autoreverses:true),value:floatKing)

                    HStack {
                        homeBubble("checklist","المهام",.missions,.purple)
                        Spacer()
                        homeBubble("gift.fill","الأحداث",.events,.orange)
                    }
                    .padding(.horizontal,18)
                    .padding(.bottom,34)
                }
                .frame(height:230)

                VStack(spacing:10) {
                    HStack {
                        VStack(alignment:.leading,spacing:3) {
                            Text("الحديقة الملكية").font(.headline.bold()).foregroundStyle(RoyalTheme.navy)
                            Text("التجديد \(game.save.renovationStage)/6")
                                .font(.caption.bold()).foregroundStyle(.gray)
                        }
                        Spacer()
                        ProgressView(value:Double(game.save.renovationStage),total:6)
                            .tint(.green).frame(width:105)
                    }

                    RoyalButton(title:"ابدأ اللعب",icon:"play.fill") { game.go(.map) }

                    HStack(spacing:8) {
                        mini("hammer.fill","التجديد",.renovation)
                        mini("crown.fill","المناطق",.regions)
                        mini("storefront.fill","المتجر",.shop)
                    }
                }
                .padding(14)
                .background(.ultraThinMaterial,in:RoundedRectangle(cornerRadius:26))
                .overlay(RoundedRectangle(cornerRadius:26).stroke(RoyalTheme.gold,lineWidth:3))
                .shadow(color:.black.opacity(0.25),radius:10,y:5)
                .padding(.horizontal,14)
                .padding(.bottom,8)

                BottomRoyalNav().environmentObject(game)
            }
        }
        .onAppear { floatKing=true }
    }

    private func homeBubble(_ icon:String,_ title:String,_ target:CrownStore.Screen,_ color:Color)->some View {
        Button { game.go(target) } label: {
            VStack(spacing:3) {
                Image(systemName:icon).font(.title2.bold()).foregroundStyle(.white)
                    .frame(width:52,height:52).background(color.gradient,in:Circle())
                    .overlay(Circle().stroke(.white,lineWidth:3))
                    .shadow(color:.black.opacity(0.25),radius:4,y:3)
                Text(title).font(.caption2.bold()).foregroundStyle(.white)
                    .shadow(color:.black,radius:2)
            }
        }.buttonStyle(.plain)
    }

    private func mini(_ icon:String,_ title:String,_ target:CrownStore.Screen)->some View {
        Button { game.go(target) } label: {
            VStack(spacing:4) {
                Image(systemName:icon).font(.title3.bold())
                Text(title).font(.caption2.bold())
            }
            .foregroundStyle(RoyalTheme.navy)
            .frame(maxWidth:.infinity)
            .padding(.vertical,7)
            .background(.white.opacity(0.65),in:RoundedRectangle(cornerRadius:14))
        }.buttonStyle(.plain)
    }
}

struct MissionsView: View {
    @EnvironmentObject var game: CrownStore
    var body: some View {
        RoyalListScreen(title: "المهام") {
            mission("sparkles", "اجمع 500 قطعة", game.save.gemsCleared, 500, .blue)
            mission("crown.fill", "افز في 30 مستوى", game.save.levelsWon, 30, .orange)
            mission("burst.fill", "استخدم 20 معززًا", game.save.boostersUsed, 20, .purple)
            mission("hammer.fill", "أكمل 6 تجديدات", game.save.renovationStage, 6, .green)
        }.environmentObject(game)
    }
    private func mission(_ icon:String,_ title:String,_ value:Int,_ goal:Int,_ color:Color)->some View {
        RoyalPanel {
            HStack {
                ZStack {
                    Circle().fill(color.gradient).frame(width:50,height:50)
                    Image(systemName:icon).font(.title3.bold()).foregroundStyle(.white)
                }
                VStack(alignment:.leading,spacing:7) {
                    Text(title).font(.headline).foregroundStyle(RoyalTheme.navy)
                    ProgressView(value:Double(min(value,goal)),total:Double(goal)).tint(.green)
                    Text("\(min(value,goal))/\(goal)").font(.caption.bold()).foregroundStyle(.gray)
                }
                Spacer()
                Image(systemName:value>=goal ? "checkmark.seal.fill":"gift.fill")
                    .font(.title2).foregroundStyle(value>=goal ? .green:.purple)
            }
        }
    }
}

struct EventsView: View {
    @EnvironmentObject var game: CrownStore
    var body: some View {
        RoyalListScreen(title: "الأحداث") {
            event("balloon.2.fill", "رحلة الملوك", "اربح مستويات متتالية", .purple, game.save.levelsWon % 10, 10)
            event("crown.fill", "تحدي التاج", "اجمع النجوم الملكية", .orange, game.save.stars % 30, 30)
            event("sparkles", "جامع الجواهر", "امسح 1000 قطعة", .blue, game.save.gemsCleared % 1000, 1000)
        }.environmentObject(game)
    }
    private func event(_ icon:String,_ title:String,_ subtitle:String,_ color:Color,_ value:Int,_ goal:Int)->some View {
        RoyalPanel {
            HStack {
                ZStack {
                    RoundedRectangle(cornerRadius:16).fill(color.gradient).frame(width:82,height:76)
                    Image(systemName:icon).font(.largeTitle).foregroundStyle(.white)
                }
                VStack(alignment:.leading,spacing:5) {
                    Text(title).font(.title3.bold()).foregroundStyle(RoyalTheme.navy)
                    Text(subtitle).font(.caption).foregroundStyle(.gray)
                    ProgressView(value:Double(value),total:Double(goal)).tint(color)
                    Text("\(value)/\(goal)").font(.caption2.bold()).foregroundStyle(.gray)
                }
                Spacer()
            }
        }
    }
}

struct ShopView: View {
    @EnvironmentObject var game: CrownStore
    var body: some View {
        RoyalListScreen(title: "المتجر") {
            HStack {
                product("hammer.fill","مطرقة",100,game.save.hammer,"hammer",.purple)
                product("shuffle","خلط",100,game.save.shuffle,"shuffle",.red)
            }
            HStack {
                product("burst.fill","قنبلة",125,game.save.bombs,"bomb",.orange)
                product("arrow.left.and.right.circle.fill","صاروخ",125,game.save.rockets,"rocket",.red)
            }
            product("sparkles","كرة الألوان",150,game.save.rainbows,"rainbow",.blue)
        }.environmentObject(game)
    }
    private func product(_ icon:String,_ name:String,_ price:Int,_ owned:Int,_ key:String,_ color:Color)->some View {
        RoyalPanel {
            VStack(spacing:9) {
                ZStack {
                    Circle().fill(color.gradient).frame(width:62,height:62)
                    Image(systemName:icon).font(.title2.bold()).foregroundStyle(.white)
                }
                Text(name).font(.headline).foregroundStyle(RoyalTheme.navy)
                Text("لديك ×\(owned)").font(.caption.bold()).foregroundStyle(.gray)
                Button { game.buyBooster(key) } label: {
                    Label("\(price)",systemImage:"circle.fill")
                        .font(.subheadline.bold()).foregroundStyle(.white)
                        .padding(.horizontal,14).padding(.vertical,7)
                        .background(game.save.coins>=price ? Color.green:Color.gray,in:Capsule())
                }.buttonStyle(.plain).disabled(game.save.coins<price)
            }
            .frame(maxWidth:.infinity)
        }
    }
}

struct RegionsView: View {
    @EnvironmentObject var game: CrownStore
    var body: some View { RoyalListScreen(title: "المناطق") {
        region("القصر الملكي","12/12",true,.orange);region("الحدائق","8/12",true,.green);region("النوافير","5/12",true,.blue);region("السوق الملكي","0/12",false,.purple);region("الشاطئ الذهبي","0/12",false,.cyan)
    }.environmentObject(game)}
    private func region(_ title:String,_ progress:String,_ open:Bool,_ color:Color)->some View {
        RoyalPanel { HStack{RoundedRectangle(cornerRadius:14).fill(color.gradient).frame(width:82,height:58).overlay(Image(systemName:open ? "building.columns.fill":"lock.fill").foregroundStyle(.white).font(.title));VStack(alignment:.leading){Text(title).font(.headline).foregroundStyle(RoyalTheme.navy);Text(progress).font(.caption.bold()).foregroundStyle(.gray)};Spacer();Image(systemName:open ? "checkmark.circle.fill":"lock.fill").foregroundStyle(open ? .green:.gray)} }
    }
}

struct SettingsScreen: View {
    @EnvironmentObject var game: CrownStore
    var body: some View { RoyalListScreen(title: "الإعدادات") {
        RoyalPanel { VStack(spacing:16){Toggle("المؤثرات الصوتية",isOn:$game.sound);Toggle("الاهتزاز",isOn:$game.haptics);HStack{Text("اللغة");Spacer();Text("العربية").foregroundStyle(.secondary)};Divider();Label("مساعدة ودعم",systemImage:"headphones");Label("سياسة الخصوصية",systemImage:"shield.fill");Label("معلومات التطبيق",systemImage:"info.circle.fill")}.foregroundStyle(RoyalTheme.navy) }
    }.environmentObject(game)}
}

struct RenovationView: View {
    @EnvironmentObject var game: CrownStore
    private var cost: Int { max(1, game.save.renovationStage + 1) }
    private var progress: Double { Double(game.save.renovationStage) / 6.0 }

    var body: some View {
        ZStack {
            RoyalWorldBackground()
            VStack(spacing: 12) {
                TopCurrencyBar().environmentObject(game)
                Spacer()
                RoyalPanel {
                    VStack(spacing: 14) {
                        RoyalHeader(title: "تجديد الحديقة")
                        ZStack {
                            Circle().fill(.blue.opacity(0.16)).frame(width: 110, height: 110)
                            Image(systemName: renovationIcon)
                                .font(.system(size: 62, weight: .bold))
                                .foregroundStyle(game.save.renovationStage >= 6 ? .green : .blue)
                        }
                        Text(renovationTitle)
                            .font(.title2.bold()).foregroundStyle(RoyalTheme.navy)
                        ProgressView(value: progress).tint(.green)
                        Text("\(Int(progress * 100))%")
                            .font(.headline.bold()).foregroundStyle(RoyalTheme.navy)
                        HStack {
                            Label("\(game.save.renovationPoints)", systemImage: "star.circle.fill")
                                .foregroundStyle(.orange)
                            Spacer()
                            Text(game.save.renovationStage >= 6 ? "اكتمل التجديد" : "التكلفة: \(cost)")
                                .font(.subheadline.bold()).foregroundStyle(.gray)
                        }
                        if game.save.renovationStage < 6 {
                            RoyalButton(title: "نفّذ التجديد • \(cost)", icon: "hammer.fill") {
                                game.renovate()
                            }
                            .opacity(game.save.renovationPoints >= cost ? 1 : 0.45)
                        } else {
                            Label("الحديقة الملكية مكتملة!", systemImage: "crown.fill")
                                .font(.headline.bold()).foregroundStyle(.green)
                        }
                    }
                }
                .padding(.horizontal, 20)
                Spacer()
                BottomRoyalNav().environmentObject(game)
            }
        }
    }

    private var renovationTitle: String {
        ["النافورة القديمة","الممر الملكي","حديقة الورود","بوابة القصر","الجناح الذهبي","الساحة الملكية","الحديقة مكتملة"][min(game.save.renovationStage, 6)]
    }

    private var renovationIcon: String {
        ["drop.fill","road.lanes","camera.macro","door.left.hand.open","building.columns.fill","crown.fill","sparkles"][min(game.save.renovationStage, 6)]
    }
}

struct RoyalListScreen<Content: View>: View {
    @EnvironmentObject var game: CrownStore
    let title:String
    @ViewBuilder let content:Content
    init(title:String,@ViewBuilder content:()->Content){self.title=title;self.content=content()}
    var body:some View {
        ZStack {
            LinearGradient(colors:[Color(red:0.12,green:0.42,blue:0.72),Color(red:0.06,green:0.18,blue:0.40)],startPoint:.top,endPoint:.bottom).ignoresSafeArea()
            VStack(spacing:10) {
                TopCurrencyBar().environmentObject(game)
                RoyalHeader(title:title).padding(.horizontal,20)
                ScrollView { VStack(spacing:12){content}.padding(16) }
                BottomRoyalNav().environmentObject(game)
            }
        }
    }
}

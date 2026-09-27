import SwiftUI

struct RoyalHomeView: View {
    @EnvironmentObject var game: CrownStore
    var body: some View {
        ZStack {
            RoyalWorldBackground()
            VStack(spacing: 12) {
                TopCurrencyBar().environmentObject(game)
                Spacer()
                VStack(spacing: 4) {
                    Image(systemName: "crown.fill").font(.system(size: 70, weight: .black)).foregroundStyle(.yellow)
                        .shadow(color: .orange, radius: 12)
                    Text("CROWN GARDENS").font(.system(size: 36, weight: .black, design: .rounded))
                        .foregroundStyle(.white).shadow(color: .black.opacity(0.6), radius: 3, y: 3)
                    Text("حدائق التاج").font(.title3.bold()).foregroundStyle(.yellow)
                }
                Spacer()
                RoyalPanel {
                    VStack(spacing: 12) {
                        Text("أعد الحياة إلى الحديقة الملكية").font(.headline.bold()).foregroundStyle(RoyalTheme.navy)
                        RoyalButton(title: "ابدأ اللعب", icon: "play.fill") { game.go(.map) }
                        HStack {
                            mini("checklist", "المهام", .missions)
                            mini("gift.fill", "الأحداث", .events)
                            mini("storefront.fill", "المتجر", .shop)
                        }
                    }
                }
                .padding(.horizontal, 20)
                BottomRoyalNav().environmentObject(game)
            }
        }
    }
    private func mini(_ icon: String, _ title: String, _ target: CrownStore.Screen) -> some View {
        Button { game.go(target) } label: {
            VStack { Image(systemName: icon).font(.title2); Text(title).font(.caption.bold()) }
                .foregroundStyle(RoyalTheme.navy).frame(maxWidth: .infinity)
        }.buttonStyle(.plain)
    }
}

struct MissionsView: View {
    @EnvironmentObject var game: CrownStore
    let missions = [
        ("heart.fill", "اجمع 500 قطعة حمراء", 320, 500),
        ("scope", "أكمل 30 مستوى", 12, 30),
        ("burst.fill", "استخدم 10 معززات", 6, 10),
        ("shippingbox.fill", "افتح 5 صناديق", 3, 5)
    ]
    var body: some View { RoyalListScreen(title: "المهام اليومية") {
        ForEach(Array(missions.enumerated()), id: \.offset) { _, m in
            RoyalPanel {
                HStack {
                    Image(systemName: m.0).font(.title).foregroundStyle(.red).frame(width: 42)
                    VStack(alignment: .leading, spacing: 7) {
                        Text(m.1).font(.headline).foregroundStyle(RoyalTheme.navy)
                        ProgressView(value: Double(m.2), total: Double(m.3)).tint(.green)
                        Text("\(m.2)/\(m.3)").font(.caption.bold()).foregroundStyle(.gray)
                    }
                    Image(systemName: "gift.fill").foregroundStyle(.purple).font(.title2)
                }
            }
        }
    }.environmentObject(game)}
}

struct EventsView: View {
    @EnvironmentObject var game: CrownStore
    var body: some View { RoyalListScreen(title: "الأحداث") {
        event("balloon.2.fill", "رحلة الملوك", "يوم و 14 ساعة", .purple)
        event("crown.fill", "تحدي التاج", "3 أيام و 12 ساعة", .orange)
        event("star.fill", "جامع النجوم", "5 أيام و 8 ساعات", .blue)
    }.environmentObject(game)}
    private func event(_ icon:String,_ title:String,_ time:String,_ color:Color)->some View {
        RoyalPanel { HStack { ZStack { RoundedRectangle(cornerRadius:16).fill(color.gradient).frame(width:82,height:70);Image(systemName:icon).font(.largeTitle).foregroundStyle(.white) };VStack(alignment:.leading){Text(title).font(.title3.bold()).foregroundStyle(RoyalTheme.navy);Label(time,systemImage:"clock.fill").font(.caption).foregroundStyle(.gray)};Spacer() } }
    }
}

struct ShopView: View {
    @EnvironmentObject var game: CrownStore
    var body: some View { RoyalListScreen(title: "المتجر") {
        HStack { product("hammer.fill","مطرقة",100);product("arrow.left.and.right","صاروخ",100);product("paintpalette.fill","كرة الألوان",150) }
        HStack { product("burst.fill","قنبلة",125);product("arrow.left.arrow.right","سهم مزدوج",150);product("crown.fill","تاج ملكي",250) }
    }.environmentObject(game)}
    private func product(_ icon:String,_ name:String,_ price:Int)->some View {
        RoyalPanel { VStack(spacing:8){Image(systemName:icon).font(.largeTitle).foregroundStyle(.purple);Text(name).font(.caption.bold()).foregroundStyle(RoyalTheme.navy);Label("\(price)",systemImage:"circle.fill").font(.caption.bold()).foregroundStyle(.orange)} }.frame(maxWidth:.infinity)
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

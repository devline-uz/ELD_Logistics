package main

import "fmt"

// This file generates the filler rows layered on top of the curated roster in
// data.go: enough drivers, units, trailers and shipping documents that every
// admin panel list screen paginates instead of showing a handful of rows. The
// curated entries stay first (and keep their exact ids) because violations.go,
// inspections.go and ops.go address specific low driver/unit indexes for their
// hand-written scenarios.

// genFirstNamesUS and genLastNamesUS are combined with a stride so the same
// pair does not repeat until every combination has been used once.
var genFirstNamesUS = []string{
	"Michael", "Jennifer", "David", "Sarah", "Christopher", "Jessica", "Matthew", "Amanda",
	"Joshua", "Ashley", "Andrew", "Emily", "Daniel", "Elizabeth", "Ryan", "Megan",
	"Brandon", "Lauren", "Justin", "Rachel", "William", "Nicole", "Anthony", "Stephanie",
}

var genLastNamesUS = []string{
	"Anderson", "Thompson", "Martinez", "Robinson", "Clark", "Rodriguez", "Lewis", "Walker",
	"Hall", "Allen", "Young", "Hernandez", "King", "Wright", "Scott", "Green",
	"Baker", "Adams", "Nelson", "Hill", "Ramirez", "Campbell", "Mitchell", "Roberts",
}

var genFirstNamesUZ = []string{
	"Bobur", "Malika", "Shavkat", "Zarina", "Ulugbek", "Nilufar", "Farrux", "Gulnora",
	"Sherzod", "Madina", "Jahongir", "Dilnoza", "Rustam", "Sevara", "Bekzod", "Aziza",
	"Davron", "Nargiza", "Alisher", "Feruza",
}

var genLastNamesUZ = []string{
	"Yusupov", "Karimova", "Rashidov", "Tosheva", "Nazarov", "Xolmatova", "Sobirov", "Rustamova",
	"Qodirov", "Yoqubova", "Mirzayev", "Saidova", "Tursunov", "Abdullayeva", "Ismoilov", "Norova",
	"Xalilov", "Ergasheva", "Junaydullayev", "Islomova",
}

// fleetMakers cycles over the truck models the generated units are given.
var fleetMakers = []struct{ Make, Model string }{
	{"Freightliner", "Cascadia 126"}, {"Volvo", "VNL 760"}, {"Kenworth", "T680"},
	{"Peterbilt", "579"}, {"International", "LT625"}, {"Mack", "Anthem"},
	{"Freightliner", "Cascadia 116"}, {"Volvo", "VNR 640"}, {"Kenworth", "W900"},
	{"Peterbilt", "389"}, {"Mack", "Pinnacle"}, {"International", "HX520"},
}

// uzFleetMakers is the same idea for the Silk Road (metric) fleet.
var uzFleetMakers = []struct{ Make, Model string }{
	{"MAN", "TGX 18.480"}, {"Isuzu", "Giga"}, {"MAN", "TGX 26.440"},
	{"Hyundai", "Xcient"}, {"Isuzu", "Forward"}, {"MAN", "TGS 33.480"},
	{"Volvo", "FH16"}, {"Scania", "R450"},
}

// genOnebookDrivers appends synthetic drivers numbered from startNum onward.
func genOnebookDrivers(startNum, count int) []driverSpec {
	branches := []string{"chicago", "dallas"}
	out := make([]driverSpec, 0, count)
	for i := 0; i < count; i++ {
		num := startNum + i
		username := fmt.Sprintf("driver%d", num)
		first := genFirstNamesUS[i%len(genFirstNamesUS)]
		last := genLastNamesUS[(i*7+3)%len(genLastNamesUS)]
		branch := branches[i%len(branches)]

		city, state, zip, addr1, region, areaCode := "Chicago", "IL", fmt.Sprintf("606%02d", i%99), fmt.Sprintf("%d W Fulton Market", 100+i), "US-IL", "312"
		terminal := "Chicago Terminal"
		if branch == "dallas" {
			city, state, zip, addr1, region, areaCode = "Dallas", "TX", fmt.Sprintf("752%02d", i%99), fmt.Sprintf("%d S Lamar St", 100+i), "US-TX", "214"
			terminal = "Dallas Terminal"
		}

		out = append(out, driverSpec{
			Username: username, First: first, Last: last,
			Email:         fmt.Sprintf("%s@onebook-logistics.test", username),
			Phone:         fmt.Sprintf("+1-%s-555-%04d", areaCode, 1000+i),
			License:       fmt.Sprintf("S%03d-%04d-%04d", i%900, (i*13)%9000, (i*29)%9000),
			LicenseRegion: region, HomeTerminal: terminal,
			City: city, State: state, Zip: zip, Address1: addr1, Branch: branch,
		})
	}
	return out
}

// genOnebookUnits appends synthetic power units numbered from startNum onward.
func genOnebookUnits(startNum, count int) []unitSpec {
	branches := []string{"chicago", "dallas"}
	out := make([]unitSpec, 0, count)
	for i := 0; i < count; i++ {
		num := startNum + i
		mk := fleetMakers[i%len(fleetMakers)]
		branch := branches[i%len(branches)]
		plateState, plateRegion := "IL", "US-IL"
		if branch == "dallas" {
			plateState, plateRegion = "TX", "US-TX"
		}
		fuel := "diesel"
		if num%23 == 0 {
			fuel = "cng"
		}
		out = append(out, unitSpec{
			Number: fmt.Sprintf("T-%d", num), Make: mk.Make, Model: mk.Model,
			VIN:         fmt.Sprintf("1FUJ%06dX%04dAA", num, num*7%10000),
			Plate:       fmt.Sprintf("%s %05d%s", plateState, 10000+num, string(rune('A'+num%26))),
			PlateRegion: plateRegion, Fuel: fuel, GVWR: "Class 8", Branch: branch,
			Year: 2019 + num%7, Sleeper: num%3 != 0,
		})
	}
	return out
}

// genSilkroadDrivers is the Silk Road (Uzbek) equivalent of genOnebookDrivers.
func genSilkroadDrivers(startNum, count int) []driverSpec {
	regions := []struct{ code, city, abbr string }{
		{"UZ-TK", "Toshkent", "TK"}, {"UZ-SA", "Samarqand", "SA"}, {"UZ-BU", "Buxoro", "BU"},
	}
	out := make([]driverSpec, 0, count)
	for i := 0; i < count; i++ {
		num := startNum + i
		username := fmt.Sprintf("silkdriver%d", num)
		first := genFirstNamesUZ[i%len(genFirstNamesUZ)]
		last := genLastNamesUZ[(i*7+3)%len(genLastNamesUZ)]
		r := regions[i%len(regions)]

		out = append(out, driverSpec{
			Username: username, First: first, Last: last,
			Email:         fmt.Sprintf("driver%d@silkroad-transport.test", num),
			Phone:         fmt.Sprintf("+998-90-100-%04d", 1000+i),
			License:       fmt.Sprintf("AB-%04d-%04d", (i*11)%9000, (i*31)%9000),
			LicenseRegion: r.code, HomeTerminal: "Toshkent Baza",
			City: r.city, State: r.abbr, Zip: fmt.Sprintf("1%04d", i%9999),
			Address1: fmt.Sprintf("Mustaqillik ko'chasi %d", 10+i), Branch: "tashkent",
		})
	}
	return out
}

// genSilkroadUnits is the Silk Road equivalent of genOnebookUnits.
func genSilkroadUnits(startNum, count int) []unitSpec {
	out := make([]unitSpec, 0, count)
	for i := 0; i < count; i++ {
		num := startNum + i
		mk := uzFleetMakers[i%len(uzFleetMakers)]
		fuel := "diesel"
		if num%11 == 0 {
			fuel = "cng"
		}
		gvwr := "Class 8"
		if num%7 == 0 {
			gvwr = "Class 7"
		}
		out = append(out, unitSpec{
			Number: fmt.Sprintf("UZ-%02d", num), Make: mk.Make, Model: mk.Model,
			VIN:         fmt.Sprintf("WMA%08dXZ%04d", num, num*3%10000),
			Plate:       fmt.Sprintf("01 A %03d %s", 100+num, string([]byte{byte('A' + num%26), byte('A' + (num*3)%26)})),
			PlateRegion: "UZ-TK", Fuel: fuel, GVWR: gvwr, Branch: "tashkent",
			Year: 2019 + num%6, Sleeper: num%2 == 0,
		})
	}
	return out
}

// genNumbered generates count sequential asset numbers such as TR-211.
func genNumbered(prefix string, start, count int) []string {
	out := make([]string, 0, count)
	for i := 0; i < count; i++ {
		out = append(out, fmt.Sprintf("%s-%03d", prefix, start+i))
	}
	return out
}

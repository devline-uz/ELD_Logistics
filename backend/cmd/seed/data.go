package main

import (
	"strings"

	"github.com/google/uuid"
)

// Credentials handed to every seeded account. Both satisfy the auth policy
// (10+ characters mixing letters and digits, a 6 digit PIN).
const (
	defaultPassword = "Onebook2026"
	defaultPIN      = "246810"
)

// Default role names copied onto every tenant by the company provisioning.
const (
	roleAdministrator = "Administrator"
	roleSubAdmin      = "Sub Admin"
	roleFleetManager  = "Fleet Manager"
	roleDispatcher    = "Dispatcher"
	roleServiceMgr    = "Service Manager"
	roleSafetyManager = "Safety Manager"
	roleDataAnalyst   = "Data Analyst"
	roleDriver        = "Driver"
)

// seedNamespace makes every generated id a deterministic function of its key,
// so the seed is idempotent: a second run updates the same rows instead of
// duplicating the dataset.
var seedNamespace = uuid.MustParse("1f7f0b30-2c4c-4c8e-9b1a-2d3e4f5a6b7c")

// sid derives the stable id of one seeded row.
func sid(kind string, parts ...string) uuid.UUID {
	return uuid.NewSHA1(seedNamespace, []byte(kind+"/"+strings.Join(parts, "/")))
}

// branchSpec is one terminal of a tenant.
type branchSpec struct {
	Key, Name, Address, Timezone string
}

// accountSpec is one office (non driver) account.
type accountSpec struct {
	Username, First, Last, Role, Email, Phone, Branch string
}

// driverSpec is one driver account together with its drivers row.
type driverSpec struct {
	Username, First, Last, Email, Phone  string
	License, LicenseRegion, HomeTerminal string
	City, State, Zip, Address1, Branch   string
}

// unitSpec is one power unit.
type unitSpec struct {
	Number, Make, Model, VIN, Plate, PlateRegion, Fuel, GVWR, Branch string
	Year                                                             int
	Sleeper                                                          bool
}

// tenantSpec is everything needed to provision one company.
type tenantSpec struct {
	Key, Name, Address, HomeTerminal, Timezone     string
	Email, Phone, Registration, Region, Regulation string
	UnitSystem, Plan, Subscription                 string
	SubscriptionDays                               int
	Branches                                       []branchSpec
	Accounts                                       []accountSpec
	Drivers                                        []driverSpec
	Units                                          []unitSpec
	Trailers                                       []string
	ShippingDocs                                   []string
}

// onebook is the main demo tenant: a US carrier with a full dataset.
var onebook = tenantSpec{
	Key:          "onebook",
	Name:         "Onebook Logistics LLC",
	Address:      "1200 W Fulton Market, Chicago, IL 60607",
	HomeTerminal: "Chicago Terminal, 1200 W Fulton Market, Chicago, IL 60607",
	Timezone:     "America/Chicago",
	Email:        "ops@onebook-logistics.test",
	Phone:        "+1-312-555-0100",
	Registration: "USDOT 3421887",
	Region:       "US",
	Regulation:   "us_fmcsa",
	UnitSystem:   "imperial",
	Plan:         "professional",
	Subscription: "active",

	SubscriptionDays: 300,
	Branches: []branchSpec{
		{"chicago", "Chicago HQ", "1200 W Fulton Market, Chicago, IL 60607", "America/Chicago"},
		{"dallas", "Dallas Terminal", "4400 S Lamar St, Dallas, TX 75215", "America/Chicago"},
	},
	Accounts: []accountSpec{
		{"admin", "Alex", "Morgan", roleAdministrator, "admin@onebook-logistics.test", "+1-312-555-0101", "chicago"},
		{"subadmin", "Priya", "Raman", roleSubAdmin, "subadmin@onebook-logistics.test", "+1-312-555-0102", "chicago"},
		{"fleet", "Daniel", "Brooks", roleFleetManager, "fleet@onebook-logistics.test", "+1-312-555-0103", "chicago"},
		{"dispatch", "Sofia", "Alvarez", roleDispatcher, "dispatch@onebook-logistics.test", "+1-312-555-0104", "chicago"},
		{"service", "Victor", "Hale", roleServiceMgr, "service@onebook-logistics.test", "+1-214-555-0105", "dallas"},
		{"safety", "Grace", "Okafor", roleSafetyManager, "safety@onebook-logistics.test", "+1-312-555-0106", "chicago"},
		{"analyst", "Ethan", "Wu", roleDataAnalyst, "analyst@onebook-logistics.test", "+1-312-555-0107", "chicago"},
	},
	Drivers: append([]driverSpec{
		{"driver1", "James", "Carter", "driver1@onebook-logistics.test", "+1-312-555-0201",
			"S412-8874-1290", "US-IL", "Chicago Terminal", "Chicago", "IL", "60607", "1200 W Fulton Market", "chicago"},
		{"driver2", "Maria", "Lopez", "driver2@onebook-logistics.test", "+1-312-555-0202",
			"S330-1145-7781", "US-IL", "Chicago Terminal", "Chicago", "IL", "60612", "2140 W Ogden Ave", "chicago"},
		{"driver3", "Ahmed", "Yusuf", "driver3@onebook-logistics.test", "+1-214-555-0203",
			"T908-2213-4460", "US-TX", "Dallas Terminal", "Dallas", "TX", "75215", "4400 S Lamar St", "dallas"},
		{"driver4", "Robert", "King", "driver4@onebook-logistics.test", "+1-214-555-0204",
			"T771-6650-0912", "US-TX", "Dallas Terminal", "Dallas", "TX", "75211", "3125 Duncanville Rd", "dallas"},
		{"driver5", "Linda", "Novak", "driver5@onebook-logistics.test", "+1-312-555-0205",
			"S119-4432-8867", "US-IL", "Chicago Terminal", "Cicero", "IL", "60804", "5410 W Cermak Rd", "chicago"},
		{"driver6", "Tom", "Becker", "driver6@onebook-logistics.test", "+1-214-555-0206",
			"T556-9081-2237", "US-TX", "Dallas Terminal", "Irving", "TX", "75061", "600 E Airport Fwy", "dallas"},
		{"driver7", "Carlos", "Mendez", "driver7@onebook-logistics.test", "+1-312-555-0207",
			"S204-7731-4409", "US-IL", "Chicago Terminal", "Chicago", "IL", "60614", "980 N Michigan Ave", "chicago"},
		{"driver8", "Angela", "Petrov", "driver8@onebook-logistics.test", "+1-214-555-0208",
			"T665-2290-1183", "US-TX", "Dallas Terminal", "Dallas", "TX", "75201", "1500 Marilla St", "dallas"},
		{"driver9", "Marcus", "Reilly", "driver9@onebook-logistics.test", "+1-312-555-0209",
			"S887-3341-9902", "US-IL", "Chicago Terminal", "Chicago", "IL", "60622", "1130 N Ashland Ave", "chicago"},
		{"driver10", "Fatima", "Haidari", "driver10@onebook-logistics.test", "+1-214-555-0210",
			"T440-1182-7765", "US-TX", "Dallas Terminal", "Irving", "TX", "75039", "400 W John Carpenter Fwy", "dallas"},
		{"driver11", "Kevin", "Walsh", "driver11@onebook-logistics.test", "+1-312-555-0211",
			"S112-9987-3345", "US-IL", "Chicago Terminal", "Chicago", "IL", "60640", "4620 N Broadway", "chicago"},
		{"driver12", "Diana", "Cho", "driver12@onebook-logistics.test", "+1-214-555-0212",
			"T229-4456-8871", "US-TX", "Dallas Terminal", "Dallas", "TX", "75220", "7800 Harry Hines Blvd", "dallas"},
	}, genOnebookDrivers(13, 208)...), // driver13..driver220
	Units: append([]unitSpec{
		{"T-101", "Freightliner", "Cascadia 126", "1FUJGLDR8LLAA1101", "IL 84210A", "US-IL", "diesel", "Class 8", "chicago", 2021, true},
		{"T-102", "Volvo", "VNL 760", "4V4NC9EH2MN1102AA", "IL 84211B", "US-IL", "diesel", "Class 8", "chicago", 2021, true},
		{"T-103", "Kenworth", "T680", "1XKYDP9X4MJ1103AB", "IL 84212C", "US-IL", "diesel", "Class 8", "chicago", 2022, true},
		{"T-104", "Peterbilt", "579", "1XPBDP9X1ND1104AC", "TX 5RTL104", "US-TX", "diesel", "Class 8", "dallas", 2022, true},
		{"T-105", "International", "LT625", "3HSDJAPR6NN1105AD", "TX 5RTL105", "US-TX", "diesel", "Class 8", "dallas", 2020, false},
		{"T-106", "Mack", "Anthem", "1M1AN4GY7LM1106AE", "TX 5RTL106", "US-TX", "diesel", "Class 8", "dallas", 2023, true},
		{"T-107", "Freightliner", "Cascadia 116", "1FUJHHDR2PL1107AF", "IL 84213D", "US-IL", "diesel", "Class 8", "chicago", 2023, false},
		{"T-108", "Volvo", "VNR 640", "4V4WC9EJ0PN1108AG", "IL 84214E", "US-IL", "cng", "Class 8", "chicago", 2024, false},
		{"T-109", "Freightliner", "Cascadia 126", "1FUJGLDR8LLAA1109", "IL 84215F", "US-IL", "diesel", "Class 8", "chicago", 2023, true},
		{"T-110", "Kenworth", "W900", "1XKAD49X8ND1110AH", "TX 5RTL110", "US-TX", "diesel", "Class 8", "dallas", 2021, true},
		{"T-111", "Volvo", "VNL 860", "4V4NC9EH5MN1111AI", "IL 84216G", "US-IL", "diesel", "Class 8", "chicago", 2022, false},
		{"T-112", "Peterbilt", "389", "1XPBDP9X6ND1112AJ", "TX 5RTL112", "US-TX", "diesel", "Class 8", "dallas", 2020, true},
		{"T-113", "Mack", "Pinnacle", "1M2AX18C0LM1113AK", "IL 84217H", "US-IL", "diesel", "Class 8", "chicago", 2024, false},
		{"T-114", "International", "LT625", "3HSDJAPR6NN1114AL", "TX 5RTL114", "US-TX", "diesel", "Class 8", "dallas", 2023, true},
	}, genOnebookUnits(115, 216)...), // T-115..T-330
	Trailers: append([]string{
		"TR-201", "TR-202", "TR-203", "TR-204", "TR-205",
		"TR-206", "TR-207", "TR-208", "TR-209", "TR-210",
	}, genNumbered("TR", 211, 140)...), // TR-211..TR-350
	ShippingDocs: append([]string{
		"BOL-90001", "BOL-90002", "BOL-90003", "BOL-90004", "BOL-90005", "BOL-90006",
		"PRO-77410", "PRO-77411", "PRO-77412", "PRO-77413",
	}, genNumbered("BOL", 90007, 140)...), // BOL-90007..BOL-90146
}

// silkroad is the second tenant. It exists so tenant isolation is visible in
// the running system: nothing it owns may appear under the Onebook accounts.
var silkroad = tenantSpec{
	Key:          "silkroad",
	Name:         "Silk Road Transport",
	Address:      "Amir Temur ko'chasi 108, Toshkent 100084",
	HomeTerminal: "Toshkent Baza, Amir Temur ko'chasi 108",
	Timezone:     "Asia/Tashkent",
	Email:        "ops@silkroad-transport.test",
	Phone:        "+998-71-200-0100",
	Registration: "UZ-TRK-114520",
	Region:       "UZ",
	Regulation:   "generic",
	UnitSystem:   "metric",
	Plan:         "starter",
	Subscription: "trial",

	SubscriptionDays: 21,
	Branches: []branchSpec{
		{"tashkent", "Toshkent Baza", "Amir Temur ko'chasi 108, Toshkent", "Asia/Tashkent"},
	},
	Accounts: []accountSpec{
		{"silkadmin", "Bekzod", "Karimov", roleAdministrator, "admin@silkroad-transport.test", "+998-90-100-0101", "tashkent"},
		{"silkfleet", "Nodira", "Yusupova", roleFleetManager, "fleet@silkroad-transport.test", "+998-90-100-0102", "tashkent"},
	},
	Drivers: append([]driverSpec{
		{"silkdriver1", "Sardor", "Tursunov", "driver1@silkroad-transport.test", "+998-90-100-0201",
			"AB-4471-2280", "UZ-TK", "Toshkent Baza", "Toshkent", "TK", "100084", "Amir Temur 108", "tashkent"},
		{"silkdriver2", "Jasur", "Ergashev", "driver2@silkroad-transport.test", "+998-90-100-0202",
			"AB-9920-3341", "UZ-SA", "Toshkent Baza", "Samarqand", "SA", "140100", "Registon 12", "tashkent"},
		{"silkdriver3", "Aziz", "Rashidov", "driver3@silkroad-transport.test", "+998-90-100-0203",
			"AB-5567-1123", "UZ-TK", "Toshkent Baza", "Toshkent", "TK", "100084", "Chilonzor 45", "tashkent"},
		{"silkdriver4", "Diyora", "Nazarova", "driver4@silkroad-transport.test", "+998-90-100-0204",
			"AB-7789-2246", "UZ-BU", "Toshkent Baza", "Buxoro", "BU", "705018", "Bukhoro kochasi 22", "tashkent"},
		{"silkdriver5", "Otabek", "Yoldashev", "driver5@silkroad-transport.test", "+998-90-100-0205",
			"AB-3321-6689", "UZ-SA", "Toshkent Baza", "Samarqand", "SA", "140100", "Registon 45", "tashkent"},
	}, genSilkroadDrivers(6, 55)...), // silkdriver6..silkdriver60
	Units: append([]unitSpec{
		{"UZ-01", "MAN", "TGX 18.480", "WMA06XZZ8NM100001", "01 A 120 AB", "UZ-TK", "diesel", "Class 8", "tashkent", 2022, true},
		{"UZ-02", "Isuzu", "Giga", "JALFVR34L07100002", "01 A 340 CD", "UZ-TK", "diesel", "Class 7", "tashkent", 2021, false},
		{"UZ-03", "MAN", "TGX 26.440", "WMA06XZZ8NM100003", "01 A 560 EF", "UZ-TK", "diesel", "Class 8", "tashkent", 2020, true},
		{"UZ-04", "Hyundai", "Xcient", "KMFHH17DPML100004", "01 A 780 GH", "UZ-TK", "diesel", "Class 8", "tashkent", 2023, true},
		{"UZ-05", "Isuzu", "Forward", "JALFVR34L07100005", "01 A 990 IJ", "UZ-TK", "diesel", "Class 7", "tashkent", 2021, false},
		{"UZ-06", "MAN", "TGS 33.480", "WMA30XZZ4LM100006", "01 A 210 KL", "UZ-TK", "diesel", "Class 8", "tashkent", 2022, true},
	}, genSilkroadUnits(7, 59)...), // UZ-07..UZ-65
	Trailers:     append([]string{"PR-11", "PR-12", "PR-13", "PR-14"}, genNumbered("PR", 15, 36)...),
	ShippingDocs: append([]string{"TTN-5001", "TTN-5002", "TTN-5003", "TTN-5004"}, genNumbered("TTN", 5005, 36)...),
}

package main

import (
	"fmt"
	"os"
	"text/tabwriter"
)

// printCredentials writes the account sheet the seeded dataset is reachable
// with. It is the whole point of running the tool, so it goes to stdout.
func printCredentials(password, pin string) {
	w := tabwriter.NewWriter(os.Stdout, 0, 4, 2, ' ', 0)

	fmt.Println()
	fmt.Println("ONEBOOK ELD — seeded accounts")
	fmt.Println("Password (every account):", password)
	fmt.Println("Driver PIN (Leave Truck / resume):", pin)
	fmt.Println()

	fmt.Fprintln(w, "TENANT\tUSERNAME\tROLE\tNAME\tEMAIL")
	fmt.Fprintf(w, "-\t%s\t%s\t%s\t%s\n", "superadmin", "Super Admin (platform)", "Platform Owner", "superadmin@onebook.test")

	for _, t := range []tenantSpec{onebook, silkroad} {
		for _, a := range t.Accounts {
			fmt.Fprintf(w, "%s\t%s\t%s\t%s %s\t%s\n", t.Name, a.Username, a.Role, a.First, a.Last, a.Email)
		}
		for _, d := range t.Drivers {
			fmt.Fprintf(w, "%s\t%s\t%s\t%s %s\t%s\n", t.Name, d.Username, roleDriver, d.First, d.Last, d.Email)
		}
	}
	_ = w.Flush()

	fmt.Println()
	fmt.Println("Notes")
	fmt.Println("  * POST /api/v1/auth/login takes {username, password, device_type}.")
	fmt.Println("    device_type is web for the office accounts, phone or tablet for drivers.")
	fmt.Println("  * Super Admin and Administrator must enrol in 2FA (TZ B§3.4): their first")
	fmt.Println("    login returns a token restricted to the /auth/2fa/setup flow. Every other")
	fmt.Println("    role signs in with the password alone.")
	fmt.Println("  * Usernames are unique per tenant; the two tenants use different ones, so no")
	fmt.Println("    company_id hint is needed on login.")
	fmt.Println()
}

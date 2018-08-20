#!/usr/bin/env node

var json = require("./chisompha.json");

var fields = ["gender", "given_name", "family_name","birthdate", "home_village", "home_ta", "home_district"];

var groups = {
    "country_of_residence": "person_attributes",
    "citizenship": "person_attributes",
    "occupation": "person_attributes",
    "home_phone_number": "person_attributes",
    "cell_phone_number": "person_attributes",
    "office_phone_number": "person_attributes",
    "race": "person_attributes",
    "given_name": "names",
    "family_name": "names",
    "middle_name": "names",
    "maiden_name": "names",
    "current_residence": "addresses",
    "current_village": "addresses",
    "current_ta": "addresses",
    "current_district": "addresses",
    "home_village": "addresses",
    "home_ta": "addresses",
    "home_district": "addresses"
}

console.log(fields.join("\t"));

for (var i = 0; i < json.length; i++) {

    var row = [];

    for (var j = 0; j < fields.length; j++) {

        var field = fields[j];

        if (groups[field]) {

            if (json[i][groups[field]][field] && String(json[i][groups[field]][field]).trim().length > 0) {

                row.push(json[i][groups[field]][field]);

            } else {

                row.push("N/A");

            }

        } else if(field == "birthdate_estimated") {

            if(String(json[i][field]).length > 0) {

                row.push(json[i][field]);

            } else {

                row.push("N/A");

            }

        } else if (json[i][field]) {

            if (json[i][field] && String(json[i][field]).trim().length > 0) {

                row.push(json[i][field]);

            } else {

                row.push("N/A");

            }

        } else {

            row.push("N/A");

        }

    }

    console.log(row.join("\t"));

}




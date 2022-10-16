const fs = require('fs');
var report = JSON.parse(fs.readFileSync('BUILD/resource_report.txt'));
var achieved = report.fmax["pll_clk_$glb_clk"].achieved;
var constraint = report.fmax["pll_clk_$glb_clk"].constraint;
var percent = achieved * 100 / constraint;
var sep = "------------ --------- ---------- ------";

console.log(sep);
console.log("CLOCKING Achieved Constraint %");
console.log("fmax " + achieved.toFixed(2) + " " + constraint + " " + percent.toFixed(2));
console.log(sep);
console.log("RESOURCE Available Used %");


Object.keys(report.utilization).forEach(
    (key,index) => {
	   var attr = report.utilization[key];
        var percent = attr.used * 100 / attr.available;
        console.log( key + " " + attr.available + " " + attr.used + " " + percent.toFixed(2))
    }
);
console.log(sep);

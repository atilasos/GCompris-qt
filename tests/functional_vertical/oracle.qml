 function plan(values) {
  var plus=activity.operation===0,compensation=activity.method===0;
  var result=plus?values.reduce((a,b)=>a+b,0):values[0]-values.slice(1).reduce((a,b)=>a+b,0);
  verify(result>=0);var adjustments=[],debt=0,width=Math.max.apply(null,values.map(n=>String(n).length))+1;
  for(var col=0;col<width;col++) {
   var digits=values.map(n=>Math.floor(n/Math.pow(10,col))%10);
   if(plus){debt=Math.floor((digits.reduce((a,b)=>a+b,0)+debt)/10);if(debt)adjustments.push([0,col+1,debt]);}
   else {
    var difference=digits[0]-digits.slice(1).reduce((a,b)=>a+b,0)-debt;
    debt=Math.max(0,Math.ceil(-difference/10));
    if(debt){adjustments.push([0,col,10*debt]);adjustments.push([compensation?values.length-1:0,col+1,compensation?debt:-debt]);}
   }
  }
  return {result:result,adjustments:adjustments};
 }

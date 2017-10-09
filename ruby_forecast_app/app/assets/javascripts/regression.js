var linearRegression = function(){
  calculate = function(X,y){

    sumXY = 0;
    n = y.length
    for (var i = 0; i < n; i++) 
    {
      impute(y, i);
      sumXY = sumXY + (y[i] * X[i]);
    }
    rxy = [];
    sumX = X.reduce(sum);
    sumY = y.reduce(sum);
    sumXSquare = X.reduce(sumsquare);
    meanX = sumX/n;
    meanY = sumY/n;
    meanXY = sumXY/n;
    meanXSquare = sumXSquare/n;
    meanSquareX = Math.pow(meanX,2);
    m = (meanXY - (meanX * meanY))/(meanXSquare - meanSquareX);
    b = meanY - m * meanX;
    for (var i = 0; i < n; i++) 
    {
      hi = y[i];
      vi = m * hi + b;
      rxy.push({x: hi, y: vi});
    }
    return rxy;
  };

  impute = function(arr, i){
    nexti = i - 1;
    if(i == 0)
      nexti = i + 1;
    val = arr[i];
    if(val === "" || isNaN(val) || val == 0)
      arr[i] = arr[nexti];
  };

  sum = function(t, i){
    return t + i;
  };
  sumsquare = function(t,i){
    return t + Math.pow(i,2);
  };
  return {
    calculate: calculate
  }
}();
/**
 * Storing here for later consideration to replace nvd3 
 * <script type="text/javascript" src="https://www.gstatic.com/charts/loader.js"></script>
 */

(function() {
  google.charts.load('current', {'packages':['corechart']});
  arrData.push([observedValues[i],predictedValues[i]]);
  google.charts.setOnLoadCallback(drawChart);
  function drawChart(){
    var dataTable = new google.visualization.DataTable();
    
    dataTable.addColumn('number', dataKey);
    dataTable.addColumn('number', dataKey + ' predicted');
    dataTable.addColumn('number', 'covariance');

    dataTable.addRows(arrData);
    var options = {
      hAxis: {title: 'observed'}
      ,vAxis: {title: 'predicted'
        ,viewWindow: {
          min: dataTable.getColumnRange(1).min
          ,max: dataTable.getColumnRange(1).max
        }
        ,viewWindowMode: 'pretty'
        ,scaleType: 'linear'
      }
      ,series: {2:{type: 'line'},0:{type:'bar'}}
    };
    var chart = new google.visualization.ComboChart(document.getElementById('chart_div'));
    chart.draw(dataTable, options);
  };
})

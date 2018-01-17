/*************************************************************
**** extracted from https://github.com/veltman/mahalanobis ***
**************************************************************/
var mahalanobis = function () { 'use strict';

  function mean(arr) {
    return sum(arr) / arr.length;
  }

  function sum(arr) {
    return arr.reduce(function(a, b){
      return a + b;
    });
  }

  function isNumeric(n) {
    return typeof n === "number" && !isNaN(n);
  }

  function sum$1(arr) {
    return arr.reduce(function(a, b){
      return a + b;
    });
  }

  function isNumeric$1(n) {
    return typeof n === "number" && !isNaN(n);
  }

  function dot$1(a, b) {
    if (a.length !== b.length) {
      throw new TypeError("Vectors are of different sizes");
    }

    return sum$1(a.map(function(x, i){
      return x * b[i];
    }));
  }

  function multiply$1(a, b) {

    var aSize = a.every(isNumeric$1) ? 1 : a.length,
        bSize = b.every(isNumeric$1) ? 1 : b.length;

    if (aSize === 1) {
      if (bSize === 1) {
        return dot$1(a, b);
      }
      return b.map(function(row){
        return dot$1(a, row);
      });
    }

    if (bSize === 1) {
      return a.map(function(row){
        return dot$1(row, b);
      });
    }

    return a.map(function(x){
      return transpose$1(b).map(function(y){
        return dot$1(x, y);
      });
    });

  }

  function transpose$1(matrix) {

    return matrix[0].map(function(d, i){

      return matrix.map(function(row){
        return row[i];
      });

    });

  }

  function cov$1(columns, means) {

    return columns.map(function(c1, i){
      return columns.map(function(c2, j){

        var terms = c1.map(function(x, k){
          return (x - means[i]) * (c2[k] - means[j]);
        });

        return sum$1(terms) / (c1.length - 1);
      });
    });

  }

  function invert$1(matrix) {

    var size = matrix.length,
        base,
        swap,
        augmented;

    // Augment w/ identity matrix
    augmented = matrix.map(function(row,i){
      return row.slice(0).concat(row.slice(0).map(function(d,j){
        return j === i ? 1 : 0;
      }));
    });

    // Process each row
    for (var r = 0; r < size; r++) {

      base = augmented[r][r];

      // Zero on diagonal, swap with a lower row
      if (!base) {

        for (var rr = r + 1; rr < size; rr++) {

          if (augmented[rr][r]) {
            // swap
            swap = augmented[rr];
            augmented[rr] = augmented[r];
            augmented[r] = swap;
            base = augmented[r][r];
            break;
          }

        }

        if (!base) {
          throw new RangeError("Matrix not invertable.");
        }

      }

      // 1 on the diagonal
      for (var c = 0; c < size * 2; c++) {

        augmented[r][c] = augmented[r][c] / base;

      }

      // Zeroes elsewhere
      for (var q = 0; q < size; q++) {

        if (q !== r) {

          base = augmented[q][r];

          for (var p = 0; p < size * 2; p++) {
              augmented[q][p] -= base * augmented[r][p];
          }

        }

      }

    }

    return augmented.map(function(row){
      return row.slice(size);
    });

  }

  function mahalanobis(data) {

    if (!Array.isArray(data)) {
      throw new TypeError("Argument must be an array.");
    }

    data.forEach(function(d){
      if (!Array.isArray(d) || d.length !== data[0].length || !d.every(isNumeric)) {
        throw new TypeError("Argument be an array of arrays of numbers, all the same length.");
      }
    });

    if (!data.length) {
      return [];
    }

    if (data.length <= data[0].length) {
      throw new RangeError("Data must have more observations (rows) than features (columns) to compute covariance. Currently has " + data.length + " observations, " + data[0].length + " features.");
    }

    var columns = transpose$1(data),
        means = columns.map(mean),
        invertedCovariance = invert$1(cov$1(columns, means));

    return data.map(function(row, i){

      var deltas = row.map(function(d, i){
        return d - means[i];
      });

      return Math.sqrt(
        multiply$1(
          multiply$1(
            deltas,
            invertedCovariance
          ),
          deltas
        )
      );

    });

  }

  return mahalanobis;

} ();
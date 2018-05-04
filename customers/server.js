var express = require('express');
var cors = require('cors')

// Set up Express environment and enable it to read and write JavaScript
var app = express();
app.use(cors());
app.use(express.bodyParser());

/*
 customers repo
 */
var customers = [
  {
    "id": 1,
    "full_name": "Mary Smith",
    "address": {
      "street": "111 Park Place",
      "city": "Reston"
    }
  },
  {
    "id": 2,
    "full_name": "Joe Johnson",
    "address": {
      "street": "10 Boardwalk Ave",
      "city": "Chicago"
    }
  }
];

app.get('/', function(req, res) {
  res.jsonp({"paths":['GET /customers', 'GET /customers/id']});
});

app.get('/customers[/]', function(req, res) {
  res.jsonp({"entities":customers});
});

/*
 GET /customers/{id}
 */
app.get('/customers/:id', function(req, res) {
  var customer = getCustomer(req.params.id);
  if(customer instanceof Object){
    res.jsonp(customer);
  } else {
    res.status(400).send({"error":"400.01", "error_msg": "customer not found."});
    //res.jsonp({"error":"400.01", "error_msg": "customer not found."})
  }
});

/*
Get a customer from the customers collection
*/
function getCustomer(id) {
  try {
    var tempId = id - 1;
    return customers[tempId];
  } catch(err) {
    return -1;
  }
}

/*
Send an error back to the client.
*/
function error(res, err) {
  res.jsonp(500, {
          'error' : JSON.stringify(err)
  });
}

function errorSummary(error, response, body) {
    return "code=" + response && response.statusCode + "&error=" + error + "&body=" + body;
}

function logError(fnName, error, response, body) {
	console.log("Error while calling " + fnName);
  console.log('statusCode:', response && response.statusCode);
  console.log('error:', error);
  console.log('body:', body);
}

// Listen for requests until the server is stopped
var port = process.env.PORT || 9000;
app.listen(port, function() {
  console.log('The server is listening on port %d', port);
});

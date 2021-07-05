import flask
from requests import get

app = flask.Flask(__name__)
app.config["DEBUG"] = True

@app.route('/status', methods=['GET'])
def getStatus():
  return "", 200

@app.route('/location', methods=['GET'])
def getLocation():
    result = get('http://ifconfig.co/country')
    return result.text

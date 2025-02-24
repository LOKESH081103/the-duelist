from flask import Flask, request, jsonify
from flask_cors import CORS
from model.resources import ResourceMatcher, DatabaseHandler

app = Flask(__name__)
CORS(app)

resource_matcher = ResourceMatcher()

@app.route('/add_resource', methods=['POST'])
def add_resource():
    data = request.json
    result = resource_matcher.add_resource(
        data['student_id'],
        {
            'type': data['type'],
            'name': data['name'],
            'description': data['description'],
            'status': data['status'],
            'cost': data['cost']
        }
    )
    return jsonify({'message': result})

@app.route('/search_resources', methods=['GET'])
def search_resources():
    query = request.args.get('query', '')
    matches = resource_matcher.find_matches(query)
    return jsonify(matches)

@app.route('/process_transaction', methods=['POST'])
def process_transaction():
    data = request.json
    points = resource_matcher.process_transaction(
        data['resource_id'],
        data['provider_id'],
        data['receiver_id']
    )
    return jsonify({'points': points})

if __name__ == '__main__':
    app.run(debug=True, port=5000)
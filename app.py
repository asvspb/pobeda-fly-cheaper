from flask import Flask, render_template, request, jsonify, Response, stream_with_context
from ticket_scraper import get_cheapest_tickets
from config import cities
import traceback
from datetime import datetime, timedelta
import json

app = Flask(__name__)

@app.route('/')
def index():
    return render_template('index.html', cities=cities)

@app.route('/search')
def search():
    @stream_with_context
    def generate():
        try:
            origin_choice = request.args.get('origin')
            destination_choice = request.args.get('destination')
            start_date_input = request.args.get('start_date', '')
            days = int(request.args.get('days', 10))

            if not start_date_input:
                start_date = datetime.now() + timedelta(days=1)
                start_date_input = start_date.strftime('%d.%m.%Y')

            for ticket in get_cheapest_tickets(
                cities[origin_choice]['code'],
                cities[destination_choice]['code'],
                start_date_input,
                days
            ):
                yield f"data: {json.dumps(ticket)}\n\n"
            
            yield f"data: {json.dumps({'finished': True})}\n\n"
        except Exception as e:
            print(traceback.format_exc())
            yield f"data: {json.dumps({'error': str(e)})}\n\n"

    return Response(generate(), content_type='text/event-stream')

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)

from flask import (
    Flask, render_template, request, send_file
)
from wand.image import (Image)
from wand.color import (Color)
from io import (BytesIO)

def create_app(test_config=None):
    # create and configure the app
    app = Flask(__name__)
    app.config['MAX_CONTENT_LENGTH'] = 25 * 1024 * 1024
    app.config['UPLOAD_FOLDER'] = "/tmp/photostrip";

    @app.route('/', methods=['GET'])
    def root():
        return render_template('root/index.html')

    @app.route('/photostrip', methods=['POST'])
    def photostrip():
        my_files = request.files.getlist('images')
        stream = BytesIO()
        with Color('#fff') as border_color:
            with Image() as img:
                for f in my_files:
                    img.gravity = 'center'
                    img.read(file=f)
                    img.auto_orient()
                img.iterator_reset()
                img.smush(stacked=True, offset=400)
                img.border(border_color, 400, 400)
                img.transform(resize='25%')
                img.format = 'png'
                img.save(file=stream)
        # Return stream to the beginning so we can send it
        stream.seek(0)
        return send_file(stream, mimetype="image/png", as_attachment=True, attachment_filename="photostrip.png", add_etags=False)

    return app

app = create_app()

if __name__ == "__main__":
    app.run()

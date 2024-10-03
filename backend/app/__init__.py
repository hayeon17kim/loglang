from flask import Flask

def create_app():
    app = Flask(__name__)

    # 앱 설정 로드
    app.config.from_pyfile('../config.py')

    # 라우트 등록
    from .routes import main
    app.register_blueprint(main)

    return app

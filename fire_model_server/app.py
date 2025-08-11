from flask import Flask, request, jsonify
from flask_cors import CORS
import torch
from PIL import Image
import os

app = Flask(__name__)
CORS(app)

# ✅ YOLOv5 모델 로드 (경로를 실제 모델 경로로 수정)
MODEL_PATH = os.path.join("runs", "train", "exp4", "weights", "best.pt")
model = torch.hub.load('ultralytics/yolov5', 'custom', path=MODEL_PATH, force_reload=False)
model.eval()

# 신뢰도 임계값을 낮춰서 더 많은 객체 감지
model.conf = 0.1  # 기본값 0.25에서 0.1로 낮춤

@app.route('/predict', methods=['POST'])
def predict():
    if 'image' not in request.files:
        return jsonify({'error': 'No image part'}), 400

    file = request.files['image']

    try:
        # ✅ 이미지 열기
        image = Image.open(file.stream).convert('RGB')

        # ✅ 모델 예측 수행
        results = model(image)

        # ✅ 디버깅: 전체 결과 정보 출력
        print("="*50)
        print("모델 예측 결과:")
        print(f"결과 개수: {len(results.pandas().xyxy)}")
        
        if len(results.pandas().xyxy[0]) > 0:
            df = results.pandas().xyxy[0]
            print(f"감지된 전체 객체 수: {len(df)}")
            print("감지된 모든 객체:")
            for idx, row in df.iterrows():
                print(f"  - 클래스: {row['name']}, 신뢰도: {row['confidence']:.3f}")
        else:
            print("감지된 객체가 없습니다.")
        
        print("모델 클래스 이름들:", model.names)
        print("="*50)

        # ✅ 결과 처리 (이곳에 들어감)
        labels = results.pandas().xyxy[0]['name'].tolist()  # 예: ['fire extinguisher', 'chair']
        
        # 다양한 소화기 관련 키워드로 검색
        fire_extinguisher_keywords = [
            'fire extinguisher', 'extinguisher', 'fire_extinguisher', 
            '소화기', 'fire-extinguisher', 'fireextinguisher'
        ]
        
        detected = any(
            any(keyword.lower() in label.lower() for keyword in fire_extinguisher_keywords)
            for label in labels
        )
        
        result = '소화기 감지됨' if detected else '소화기 없음'
        
        # 디버깅 정보 추가
        print(f"최종 감지된 객체들: {labels}")
        print(f"소화기 감지 여부: {detected}")
        print(f"최종 결과: {result}")

        return jsonify({
            'result': result,
            'detected_objects': labels,
            'fire_extinguisher_detected': detected,
            'model_classes': list(model.names.values()) if hasattr(model, 'names') else []
        })
    
    except Exception as e:
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)

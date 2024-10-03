import json
from flask import Blueprint, request, jsonify
import openai

main = Blueprint('main', __name__)

# OpenAI API 설정
openai.api_key = ''

# GPT에게 프롬프트를 보내고 응답을 받는 함수
def revise_with_gpt(content):
    prompt = f"""
    You are an English teacher. The user has written an English journal entry and wants you to correct it. Please review the text for grammar, word choice, and natural phrasing. Return the corrected version and highlight any changes in JSON format. For each change, specify the original text, the corrected text, and the reason for the correction in Korean. If a part of the text does not require any correction, leave it as is and do not include it in the response.
    Return the response in the following structured JSON format:

    {{
      "revised_jouranl": "<revised >",
      "changes": [
        {{
          "original": "<original phrase>",
          "revised": "<revised phrase>",
          "start_index": <start index of the original phrase>,
          "end_index": <end index of the original phrase>,
          "reason": "<reason for the change>"
        }}
      ]
    }}

    Original journal entry: "{content}"
    """
    
    # gpt-4o-mini 모델을 사용한 ChatCompletion 호출
    response = openai.chat.completions.create(
        model="gpt-3.5-turbo",  # "gpt-4o-mini" 모델 사용
        messages=[
            {"role": "system", "content": "You are a helpful assistant."},
            {"role": "user", "content": prompt}
        ]
    )

    chat_response = response.choices[0].message.content

    return chat_response


# 라우트: /diary, POST 방식
@main.route('/diary', methods=['POST'])
def handle_diary():
    data = request.get_json()
    content = data.get('content')

    # GPT로 문장 수정
    gpt_response = revise_with_gpt(content)

    # 응답 반환
    return jsonify(gpt_response)

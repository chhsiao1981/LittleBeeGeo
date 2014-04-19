# -*- coding: utf-8 -*-

from app.constants import S_OK, S_ERR
import random
import math
import base64
import time
import ujson as json

from app import cfg
from app import util

def p_json_handler(data):
    for each_data in data:
        the_timestamp = each_data.get('save_time', 0)
        the_id = str(the_timestamp) + "_" + util.uuid()
        each_data['the_id'] = the_id
    util.db_insert('bee', data)

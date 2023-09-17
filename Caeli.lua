JSON = require('json');
fs = require('fs');
Mooncake = require('mooncake');

base64 = require('base64');
Fluoresce = require('fluoresce');
xor = require('xor');
pb = require('pb');
protoc = require('protoc');
assert(protoc:load(fs.readFileSync('./Library/Proto/universe.proto')));
kcp = require('lutil.dll');

RandCharacterSet = "qwertyuiopasdfghjklzxcvbnm1234567890";
RandNumberSet = "1234567890";
math.randomseed(os.clock()^5);

ServerConf = {};
if (fs.existsSync('./conf.json'))
then
	ServerConf = JSON.parse(fs.readFileSync('./conf.json'));
else
	ServerConf = {
		http_port = 3000,
		udp_port = 3005,
		bind_address = "0.0.0.0",
		access_address = "0.0.0.0", -- change to server IP
		dispatch = {
			region_list = {
				{
					name = "os_usa",
					title = "Caeli",
					type = "DEV_PUBLIC",
					dispatch_url = "http://127.0.0.1/query_cur_region"
				}
			},
			custom_config = {
				sdkenv = "2",
				checkdevice = false,
				loadPatch = false,
				showexception = false,
				regionConfig = "pm|fk|add",
				downloadMode = "0",
				codeSwitch = { 40 },
				coverSwitch = { 3628 }
				
			}
		},
		run_mode = "ALL",
		ssl = false,
		cert = '',
		key = '',
		chain = ''
	};
	fs.writeFileSync('./conf.json', JSON.stringify(ServerConf, { indent = 2}));
end;

DispatchKey = fs.readFileSync('./Library/Key/DispatchKey.bin');
DispatchSeed = fs.readFileSync('./Library/Key/DispatchSeed.bin');
ClientCustomConfig = xor(JSON.stringify(ServerConf["dispatch"]["custom_config"]), DispatchKey);
SecretKey = fs.readFileSync('./Library/Key/SecretKey.bin');

function DefaultHeaders(Payload, ContentType)
	if (ContentType == nil) then ContentType = "text/plain"; end;
	local Headers = {
		['Date'] = os.date("%a, %d %b %Y %X"),
		['Content-Type'] = ContentType,
		['Content-Length'] = #Payload
	};
	return Headers;
end;
function RandomID(Length)
	local Final = {};
	for i = 1, Length do
		local res = math.random(1, #RandCharacterSet);
		table.insert(Final, RandCharacterSet:sub(res, res));
	end;
	return table.concat(Final);
end;
function RandomNumber(Length)
	local Final = {};
	for i = 1, Length do
		local res = math.random(1, #RandNumberSet);
		table.insert(Final, RandNumberSet:sub(res, res));
	end;
	return tonumber(table.concat(Final));
end;
JSON.empty_obj = setmetatable({}, {__jsontype = "object"});
JSON.empty_arr = setmetatable({}, {__jsontype = "array"});

local Caeli = Mooncake:new({
	isHttps = ServerConf['ssl'],
	keyPath = ServerConf['key']
});
Caeli:use(function(req, res, next)
	print(req.url);
	next();
end);
Caeli:start(ServerConf['http_port'], ServerConf['bind_address']);

Caeli:post("/sdk/dataUpload", function(req, res)
	local ResponseData = { code = 0 };
	local Payload = JSON.stringify(ResponseData);
	res:send(Payload, 200, DefaultHeaders(Payload));
end);
Caeli:post("/crash/dataUpload", function(req, res)
	local ResponseData = { code = 0 };
	local Payload = JSON.stringify(ResponseData);
	res:send(Payload, 200, DefaultHeaders(Payload));
end);
Caeli:post("/log", function(req, res)
	local ResponseData = { code = 0 };
	local Payload = JSON.stringify(ResponseData);
	res:send(Payload, 200, DefaultHeaders(Payload));
end);

Caeli:get("/query_region_list", function(req, res)
	local DispatchData = {
		region_list = ServerConf["dispatch"]["region_list"],
		client_secret_key = DispatchSeed,
		client_custom_config_encrypted = ClientCustomConfig,
		enable_login_pc = true
	}
	Payload = base64.encode(pb.encode("QueryRegionListHttpRsp", DispatchData));
	res:send(Payload, 200, DefaultHeaders(Payload));
end);
Caeli:get("/query_cur_region", function(req, res)
	local Payload = "CAESGE5vdCBGb3VuZCB2ZXJzaW9uIGNvbmZpZw==";
	res:send(Payload, 200, DefaultHeaders(Payload));
end);
Caeli:get('/admin/mi18n/:platform/:version/:file', function(req, res)
	if (req.params.platform == "plat_os") then
		Payload = JSON.stringify({ version = 16 });
	elseif (req.params.platform == "plat_oversea") then
		Payload = JSON.stringify({ version = 79 });
	end;
	res:send(Payload, 200, DefaultHeaders(Payload));
end);
Caeli:get('/hk4e_global/combo/granter/api/getConfig', function(req, res)
	local Response = {
		retcode = 0,
		message = "OK",
		data = {
			protocol = true,
			qr_enabled = false,
			log_level = "INFO",
			announce_url = "",
			push_alias_type = 2,
			disable_ysdk_guard = false,
			enable_announce_pic_popup = true
		}
	};
	local Payload = JSON.stringify(Response);
	res:send(Payload, 200, DefaultHeaders(Payload));
end);
Caeli:post('/hk4e_global/combo/granter/api/compareProtocolVersion', function(req, res)
	local Response = {
		message = "OK",
		retcode = 0,
		data = {
			modified = true,
			protocol = {
				app_id = 4,
				create_time = 0,
				full_priv_proto = "",
				id = 0,
				language = "en",
				major = 13,
				minimum = 0,
				priv_proto = "",
				teenager_proto = "",
				third_proto = "",
				user_proto = ""
			}
		}
	};
	local Payload = JSON.stringify(Response);
	res:send(Payload, 200, DefaultHeaders(Payload, "application/json"));
end);
Caeli:get('/hk4e_global/mdk/shield/api/loadConfig', function(req,res)
	local Response = {
		retcode = 0,
		message = "OK",
		data = {
			id = 6,
			game_key = "hk4e_global",
			client = "PC",
			identity = "I_IDENTITY",
			guest = false,
			ignore_versions = "",
			scene = "S_NORMAL",
			name = "????",
			disable_regist = false,
			enable_email_captcha = false,
			thirdparty = {"fb","tw"},
			disable_mmt = false,
			server_guest = false,
			thirdparty_ignore = {
				tw = "",
				fb = ""
			},
			enable_ps_bind_account = false,
			thirdparty_login_configs = {
				tw = {
					token_type = "TK_GAME_TOKEN",
					game_token_expires_in = 604800
					},
				fb = {
					token_type = "TK_GAME_TOKEN",
					game_token_expires_in = 604800
				}
			}
		}
	}
	local Payload = JSON.stringify(Response);
	res:send(Payload, 200, DefaultHeaders(Payload));
end);
Caeli:get('/device-fp/api/getExtList', function(req, res)
	local Response = {
		data = {
			code = 200,
			ext_list = {
				"cpuName", "deviceModel", "deviceType",
				"deviceUID", "gpuID", "gpuName", "gpuAPI",
				"gpuVendor", "gpuVersion", "gpuMemory",
				"osVersion", "cpuCores", "cpuFrequency",
				"gpuVendorID", "isGpuMultiThread", "memorySize",
				"screenSize", "engineName", "addressMAC"
			},
			msg = "ok",
			pkg_list = {},
			pkg_str = "/vK5WTh5SS3SAj8Zm0qPWg=="
		},
		message = "OK",
		retcode = 0
	}
	local Payload = JSON.stringify(Response);
	res:send(Payload, 200, DefaultHeaders(Payload, "application/json"));
end);
Caeli:post('/device-fp/api/getFp', function(req, res)
	local Response = {
		retcode = 0,
		message = "OK",
		data = {
			code = 200,
			device_fp = RandomID(12),
			msg = "ok"
		}
	};
	local Payload = JSON.stringify(Response);
	res:send(Payload, 200, DefaultHeaders(Payload, "application/json"));
end);
Caeli:get('/combo/box/api/config/sdk/combo', function(req, res)
	local Response = {
		retcode = 0,
		message = "OK",
		data = {
			vals = {
				disable_email_bind_skip = "false",
				email_bind_remind_interval = "7",
				email_bind_remind = "true"
			}
		}
	};
	local Payload = JSON.stringify(Response);
	res:send(Payload, 200, DefaultHeaders(Payload));
end);

Caeli:post('/hk4e_global/mdk/shield/api/verify', function(req, res)
	-- Login --
	local Response = {
		retcode = 0,
		message = "OK",
		data = {
			account = {
				apple_name = "",
				area_code = "**",
				country = "US",
				device_grant_ticket = "",
				email = "user@caeli.cherrymint.live",
				facebook_name = "",
				game_center_name = "",
				google_name = "",
				identity_card = "",
				is_email_verify = "0",
				mobile = "",
				name = "",
				reactivate_ticket = "",
				realname = "",
				safe_mobile = "",
				sony_name = "",
				tap_name = "",
				token = req.body['token'],
				twitter_name = "",
				uid = req.body['uid']
			},
			device_grant_required = false,
			realname_operation = "NONE",
			realperson_required = false,
			safe_mobile_required = false
		}
	};
	local Payload = JSON.stringify(Response);
	res:send(Payload, 200, DefaultHeaders(Payload, "application/json"));
end);
Caeli:post('/hk4e_global/mdk/shield/api/login', function(req, res)
	-- Login --
	local Account = req.body["account"];
	local Password = req.body["password"];
	local Response = {
		retcode = 0,
		message = "OK",
		data = {
			account = {
				apple_name = "",
				area_code = "**",
				country = "US",
				device_grant_ticket = "",
				email = "user@caeli.cherrymint.live",
				facebook_name = "",
				game_center_name = "",
				google_name = "",
				identity_card = "",
				is_email_verify = "0",
				mobile = "",
				name = "",
				reactivate_ticket = "",
				realname = "",
				safe_mobile = "",
				sony_name = "",
				tap_name = "",
				token = RandomID(32),
				twitter_name = "",
				uid = RandomNumber(10)
			},
			device_grant_required = false,
			realname_operation = "NONE",
			realperson_required = false,
			safe_mobile_required = false
		}
	};
	local Payload = JSON.stringify(Response);
	res:send(Payload, 200, DefaultHeaders(Payload, "application/json"));
end);
Caeli:post('/hk4e_global/combo/granter/login/v2/login', function(req, res)
	local Response = {
		retcode = 0,
		message = "OK",
		data = {
			account_type = 1,
			combo_id = RandomNumber(9),
			combo_token = RandomID(32),
			data = { guest = false },
			heartbeat = false,
			open_id = req.body["data"]["uid"]
		}
	};
	local Payload = JSON.stringify(Response);
	res:send(Payload, 200, DefaultHeaders(Payload, "application/json"));
end);
Caeli:get('/hk4e_global/mdk/agreement/api/getAgreementInfos', function(req, res)
	local Response = {
		retcode = 0,
		message = "OK",
		data = {
			marketing_agreements = {}
		}
	};
	local Payload = JSON.stringify(Response);
	res:send(Payload, 200, DefaultHeaders(Payload));
end);
Caeli:post('/data_abtest_api/config/experiment/list', function(req, res)
	local Response = {
		retcode = 0,
		success = true,
		message = "",
		data = {
			{
				code = 1000,
				type = 2,
				config_id = "14",
				period_id = "6039_99",
				version = "1",
				configs = { cardType = "old" }
			}
		}
	};
	local Payload = JSON.stringify(Response);
	res:send(Payload, 200, DefaultHeaders(Payload));
end);
Caeli:post('/account/risky/api/check', function(req, res)
	local Response = {
		data = {
			action = "ACTION_NONE",
			geetest = nil,
			id = RandomID(32)
		},
		message = "OK",
		retcode = 0
	};
	local Payload = JSON.stringify(Response);
	res:send(Payload, 200, DefaultHeaders(Payload));
end);

Caeli:get("/", function(req, res)
	res:send("Index", 200);
end);
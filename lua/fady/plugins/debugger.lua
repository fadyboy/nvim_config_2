return {
	"mfussenegger/nvim-dap",
	dependencies = {
		"rcarriga/nvim-dap-ui",
		"nvim-neotest/nvim-nio",
		"leoluz/nvim-dap-go",
		"theHamsta/nvim-dap-virtual-text",
	},

	config = function()
		local dap = require("dap")
		local dapui = require("dapui")

		require("dapui").setup()
		require("dap-go").setup()

		vim.keymap.set("n", "<Leader>du", ":DapUiToggle<CR>", {})
		vim.keymap.set("n", "<Leader>db", dap.set_breakpoint, {})
		vim.keymap.set("n", "<Leader>dt", dap.toggle_breakpoint, {})
		vim.keymap.set("n", "<Leader>dc", dap.continue, {})
		vim.keymap.set("n", "<Leader>dq", dap.terminate, {})

		-- custom buttons
		vim.fn.sign_define('DapBreakpoint', {text='🛑', texthl='DapBreakpoint', linehl='DapBreakpoint', numhl='DapBreakpoint'})

		-- dap go configurations
		dap.adapters.delve = function(callback, config)
		if config.mode == 'remote' and config.request == 'attach' then
			callback({
				type = 'server',
				host = config.host or '127.0.0.1',
				port = config.port or '38697'
			})
		else
			callback({
				type = 'server',
				port = '${port}',
				executable = {
						command = 'dlv',
						args = { 'dap', '-l', '127.0.0.1:${port}', '--log', '--log-output=dap' },
						detached = vim.fn.has("win32") == 0,
				}
			})
         end
      end
		--
		dap.configurations.go = {
		  {
			 type = "delve",
			 name = "Debug",
			 request = "launch",
			 program = "${file}"
		  },
		  {
			 type = "delve",
			 name = "Debug test", -- configuration for debugging test files
			 request = "launch",
			 mode = "test",
			 program = "${file}"
		  },
		  -- works with go.mod packages and sub packages 
		  {
			 type = "delve",
			 name = "Debug test (go.mod)",
			 request = "launch",
			 mode = "test",
			 program = "./${relativeFileDirname}"
		  } 
      }

		-- nvim dapui settings
		dap.listeners.before.attach.dapui_config = function()
		  dapui.open()
		end
		dap.listeners.before.launch.dapui_config = function()
		  dapui.open()
		end
		dap.listeners.before.event_terminated.dapui_config = function()
		  dapui.close()
		end
		dap.listeners.before.event_exited.dapui_config = function()
		  dapui.close()
		end
	end
}

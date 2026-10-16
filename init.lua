vim.g.mapleader = " "

local o = vim.opt
o.number = true
o.ignorecase = true
o.smartcase = true
o.termguicolors = true
o.splitright = true
o.splitbelow = true
o.wrap = true
o.linebreak = true
o.undofile = true
o.clipboard = "unnamedplus"
o.scrolloff = 5
vim.g.markdown_folding = 1 -- fold by heading
o.foldlevelstart = 99 -- start unfolded

vim.keymap.set("n", "<leader>w", "<cmd>write<cr>", { desc = "save" })
vim.keymap.set("n", "<leader>q", "<cmd>quit<cr>", { desc = "quit" })

-- gx anywhere on a markdown link: relative paths open in nvim, URLs in the browser
vim.api.nvim_create_autocmd("FileType", { pattern = "markdown", callback = function(a)
  vim.keymap.set("n", "gx", function()
    vim.treesitter.get_parser():parse(true)
    local n = vim.treesitter.get_node({ ignore_injections = false })
    while n and n:type() ~= "inline_link" do n = n:parent() end
    local dest = n and n:named_child(n:named_child_count() - 1)
    local url = dest and vim.treesitter.get_node_text(dest, 0) or vim.ui._get_urls()[1]
    if not url then return end
    if url:match("^%a[%w+.-]*:") then vim.ui.open(url)
    elseif dest then vim.cmd.edit(vim.fn.fnamemodify(vim.fn.expand("%:p:h") .. "/" .. url, ":p")) end
  end, { buffer = a.buf })
end })

local lazy = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazy) then
  vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable",
    "https://github.com/folke/lazy.nvim.git", lazy })
end
vim.opt.rtp:prepend(lazy)

require("lazy").setup({
  { "catppuccin/nvim", name = "catppuccin", priority = 1000,
    config = function() vim.cmd.colorscheme("catppuccin-mocha") end },
  { "MeanderingProgrammer/render-markdown.nvim", ft = "markdown", opts = {
    anti_conceal = { enabled = false }, -- don't reveal source on the cursor line
    heading = { icons = {}, sign = false },
    checkbox = { unchecked = { icon = "[ ]" }, checked = { icon = "[x]" } },
    bullet = { icons = { "•", "◦", "▪" } },
  } },
  { "folke/which-key.nvim", event = "VeryLazy", opts = {} },
  { "echasnovski/mini.nvim", config = function()
    require("mini.pick").setup()
    require("mini.files").setup()
    local k = vim.keymap.set
    k("n", "<leader>f", "<cmd>Pick files<cr>", { desc = "find file" })
    k("n", "<leader>/", "<cmd>Pick grep_live<cr>", { desc = "grep" })
    k("n", "<leader>b", "<cmd>Pick buffers<cr>", { desc = "buffers" })
    k("n", "<leader>e", function() MiniFiles.open(vim.api.nvim_buf_get_name(0)) end, { desc = "browse files" })
  end },
}, { performance = { rtp = { reset = false } } }) -- keep distro treesitter parsers

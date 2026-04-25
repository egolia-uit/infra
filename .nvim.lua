vim.filetype.add({
  pattern = {
    [".*ya?ml%.encrypted"] = "yaml",
    [".*json%.encrypted"] = "json",
    [".*env%.encrypted"] = "dotenv",
  },
})

---@param fname string
---@param is_input boolean
---@return string
local type_arg = function(fname, is_input)
  local type
  if fname:match("%.ya?ml%.encrypted$") then
    type = "yaml"
  elseif fname:match("%.json%.encrypted$") then
    type = "json"
  elseif fname:match("%.env%.encrypted$") then
    type = "dotenv"
  end
  if not type then
    return ""
  end
  if is_input then
    return string.format("--input-type=%s --output-type=%s ", type, type)
  else
    return string.format("--input-type=%s --output-type=%s ", type, type)
  end
end

vim.keymap.set("n", "<localleader>e", function()
  local fname = vim.fn.expand("%")
  vim.cmd(string.format("!sops --encrypt --in-place %s %s", type_arg(fname, true), fname))
  vim.cmd("edit!")
end, { desc = "SOPS | Encrypt Current Secret File" })

vim.keymap.set("n", "<localleader>d", function()
  local fname = vim.fn.expand("%")
  vim.cmd(string.format("!sops --decrypt --in-place %s %s", type_arg(fname, false), fname))
  vim.cmd("edit!")
end, { desc = "SOPS | Decrypt Current File" })

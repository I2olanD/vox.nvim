if vim.fn.has("nvim-0.8.0") ~= 1 then
  vim.api.nvim_err_writeln("Vox requires Neovim >= 0.8.0")
  return
end

if vim.g.loaded_vox then
  return
end

vim.g.loaded_vox = 1

local main_module_ok, _ = pcall(require, "vox")
if not main_module_ok then
  vim.notify("Vox: Failed to load main module. Plugin may not function correctly.", vim.log.levels.ERROR)
end

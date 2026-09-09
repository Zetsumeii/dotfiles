local status, _ = pcall(vim.cmd, "colorscheme dracula") --favorite
if not status then
    print("Colorscheme not found !")
    return
end

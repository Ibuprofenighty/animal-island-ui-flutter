# Form / 表单 workflow reference

Example source: [form_workflow_recipe.dart](../../../../example/lib/recipes/form_workflow_recipe.dart).
Check the package's exported declarations before reusing code from it.
复用示例代码前，请核对包根导出的实际声明。

What it covers: opaque typed field keys, real typed bindings, one borrowed text buffer per text field, latest-wins field validation, immutable typed submit snapshots, bool acceptance/rejection (`island-reject` simulates a server rejection), caller-handled errors, and busy or form-state-changed/cancelled outcomes. / 不透明类型化字段 key、真实类型化 binding、每个文本字段唯一的借用缓冲区、字段验证 latest-wins、不可变类型化提交快照、bool 接受/拒绝（`island-reject` 模拟服务端拒绝）、调用者处理错误，以及 busy 或表单状态改变/取消结果。

See [workflows](../../../../docs/en/workflows.md) /
[中文](../../../../docs/zh/workflows.md).

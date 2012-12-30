public struct CodeGeneratorRequest
{
    string[] file_to_generate;
    string? parameter;
    FileDescriptorProto[] proto_file;
}

public struct CodeGeneratorResponse
{
    string? error;
    File[] file;
}

public struct File
{
    string? name;
    string? insertion_point;
    string? content;
}

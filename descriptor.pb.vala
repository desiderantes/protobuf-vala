public struct FileDescriptorSet
{
    FileDescriptorProto[] file;
}

public struct FileDescriptorProto
{
    string? name;
    string? package;
    string[] dependency;
    DescriptorProto[] message_type;
    EnumDescriptorProto[] enum_type;
    ServiceDescriptorProto[] service;
    FieldDescriptorProto[] extension;
    FileOptions? options;
    SourceCodeInfo? source_code_info;
}

public struct DescriptorProto
{
    string? name;
    FieldDescriptorProto[] field;
    FieldDescriptorProto[] extension;
}

public struct FieldDescriptorProto
{
}

public struct EnumDescriptorProto
{
}

public struct ServiceDescriptorProto
{
}

public struct FileOptions
{
}

public struct SourceCodeInfo
{
    Location[] location;
}

public struct Location
{
    int32[] path;
    int32[] span;
}

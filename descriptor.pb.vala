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
    string? name;
    int32? number;
    Label? label;
    Type? type;
    string? type_name;
    string? extendee;
    string? default_value;
    FileOptions? options;
}

public enum Type
{
    TYPE_DOUBLE = 1,
    TYPE_FLOAT = 2,
    TYPE_INT64 = 3,
    TYPE_UINT64 = 4,
    TYPE_INT32 = 5,
    TYPE_FIXED64 = 6,
    TYPE_FIXED32 = 7,
    TYPE_BOOL  = 8,
    TYPE_STRING = 9,
    TYPE_GROUP = 10,
    TYPE_MESSAGE = 11,
    TYPE_BYTES = 12,
    TYPE_UINT32 = 13,
    TYPE_ENUM  = 14,
    TYPE_SFIXED32 = 15,
    TYPE_SFIXED64 = 16,
    TYPE_SINT32 = 17,
    TYPE_SINT64 = 18
}

public enum Label
{
    LABEL_OPTIONAL = 1,
    LABEL_REQUIRED = 2,
    LABEL_REPEATED = 3
}

public struct EnumDescriptorProto
{
    string? name;
    EnumValueDescriptorProto[] value;
    //EnumOptions? options;
}

public struct EnumValueDescriptorProto
{
    string? name;
    int32? number;
    //EnumValueOptions? options;
}

public struct ServiceDescriptorProto
{
    string? name;
    //MethodDescriptorProto[] method;
    //ServiceOptions? options;
}

public struct FileOptions
{
    string? java_package;
    string? java_outer_classname;
    bool? java_multiple_files;
    bool? java_generate_equals_and_hash;
    //OptimizeMode? optimise_for;
    bool? cc_generic_services;
    bool? java_generic_services;
    bool? py_generic_services;
    //UniterpretedOption[] uninterpreted_option;
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

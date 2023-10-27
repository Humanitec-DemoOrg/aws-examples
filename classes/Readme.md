# classes

The field `class` within a matching criteria resource allows you to enter an arbitrary string, enabling specialization of resource definitions. This helps developers select various resource types and their corresponding applications.

The official usage for this feature is to customize your resource definition with different properties, allowing developers to use scores when making requests from the catalog. It is also possible to use this to organize resources by team or business unit, as the string is arbitrary.

As a platform engineer, configure your matching criteria:

```
resource "humanitec_resource_definition_criteria" "s3_kms" {
  resource_definition_id = humanitec_resource_definition.s3_kms.id
  class                  = "kms" #arbitrary string
}
```

From a developer's perspective, request the resource and specialization type using the score definition.

```
resources:
  "my-s3-sse":
    type: s3
    class: sse
```